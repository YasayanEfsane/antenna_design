% RUN_PARAMETER_SWEEP Demonstrates the effect of changing the substrate 
% thickness (h) on the antenna's bandwidth and gain.

clear; close all; clc;

disp('======================================================');
disp(' Parameter Sweep: Substrate Thickness (h) ');
disp('======================================================');

cfg = config();
% Sweep thickness from 1 mm to 3 mm in 5 steps to keep simulation time reasonable
h_values = linspace(1e-3, 3e-3, 5); 
bandwidths = zeros(size(h_values));
gains = zeros(size(h_values));

% Fast frequency sweep vector (31 points) to speed up analysis
fast_freq = linspace(cfg.f0 - 150e6, cfg.f0 + 150e6, 31); 

fprintf('Sweeping thickness from %.1f mm to %.1f mm (%d steps)...\n', ...
    h_values(1)*1e3, h_values(end)*1e3, length(h_values));

for i = 1:length(h_values)
    fprintf('Step %d/%d: h = %.2f mm... ', i, length(h_values), h_values(i)*1e3);
    
    % Update configuration
    temp_cfg = cfg;
    temp_cfg.h = h_values(i);
    temp_cfg.freq_vector = fast_freq;
    
    % Recalculate physical dimensions for the new thickness
    dim = calculate_patch_dimensions(temp_cfg);
    W_feed = calculate_microstrip_width(temp_cfg);
    
    % Build the antenna model
    ant = build_patch_antenna(temp_cfg, dim, W_feed, dim.inset_dist);
    
    try
        % 1. Calculate S-parameters
        S = sparameters(ant, fast_freq, temp_cfg.Z0);
        S11 = 20 * log10(abs(rfparam(S, 1, 1)));
        
        % 2. Calculate Bandwidth
        bw_res = calculate_bandwidth(fast_freq, S11, -10);
        if ~isnan(bw_res.fractional_BW)
            bandwidths(i) = bw_res.fractional_BW;
        else
            bandwidths(i) = 0; % No -10 dB bandwidth found
        end
        
        % 3. Calculate Gain at Center Frequency
        [D_3d, ~, ~] = pattern(ant, temp_cfg.f0);
        gains(i) = max(D_3d(:));
        fprintf('BW = %.2f%%, Gain = %.2f dBi\n', bandwidths(i), gains(i));
        
    catch ME
        fprintf('Failed: %s\n', ME.message);
        bandwidths(i) = NaN;
        gains(i) = NaN;
    end
end

disp('Plotting Sweep Results...');
if ~exist(cfg.results_dir, 'dir')
    mkdir(cfg.results_dir);
end

f_sweep = figure('Visible', 'off', 'Position', [100, 100, 800, 400]);

% Left Axis: Bandwidth
yyaxis left
plot(h_values * 1e3, bandwidths, '-o', 'LineWidth', 2);
ylabel('Fractional Bandwidth (%)');
xlabel('Substrate Thickness, h (mm)');

% Right Axis: Gain
yyaxis right
plot(h_values * 1e3, gains, '-s', 'LineWidth', 2);
ylabel('Maximum Gain (dBi)');

title('Effect of Substrate Thickness on Antenna Performance');
grid on;

% Save result
saveas(f_sweep, fullfile(cfg.results_dir, 'parameter_sweep.png'));
close(f_sweep);

disp('Parameter Sweep Complete. Check results/parameter_sweep.png.');
