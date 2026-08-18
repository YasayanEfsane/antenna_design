function plot_results(cfg, results, prefix)
% PLOT_RESULTS Generates and saves standard plots for the antenna.
%   PLOT_RESULTS(cfg, results, prefix)
%   Inputs:
%       cfg - Configuration struct
%       results - Results struct from simulate_patch_antenna
%       prefix - String prefix for saved filenames (e.g., 'analytical', 'optimized')

    if ~exist(cfg.results_dir, 'dir')
        mkdir(cfg.results_dir);
    end
    
    % S11 Plot
    f_fig = figure('Visible', 'off', 'Position', [100, 100, 800, 600]);
    plot(results.freq / 1e9, results.S11, 'LineWidth', 2);
    hold on; grid on;
    
    % -10 dB line
    yline(-10, '--r', '-10 dB Limit', 'LineWidth', 1.5);
    
    % Target Frequency Line
    xline(cfg.f0 / 1e9, '--g', '2.45 GHz Target', 'LineWidth', 1.5, 'LabelOrientation', 'horizontal');
    
    % Mark Resonance
    plot(results.f_res / 1e9, results.min_S11, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    
    title(sprintf('Reflection Coefficient (S_{11}) - %s', prefix));
    xlabel('Frequency (GHz)');
    ylabel('S_{11} (dB)');
    set(gca, 'FontSize', 12);
    legend('S_{11}', '-10 dB Threshold', 'Target Frequency', 'Resonance', 'Location', 'best');
    
    saveas(f_fig, fullfile(cfg.results_dir, sprintf('%s_s11.png', prefix)));
    close(f_fig);
    
    % VSWR Plot
    v_fig = figure('Visible', 'off', 'Position', [100, 100, 800, 600]);
    plot(results.freq / 1e9, results.vswr, 'LineWidth', 2, 'Color', [0.8500 0.3250 0.0980]);
    hold on; grid on;
    yline(2, '--r', 'VSWR = 2 Limit', 'LineWidth', 1.5);
    title(sprintf('Voltage Standing Wave Ratio (VSWR) - %s', prefix));
    xlabel('Frequency (GHz)');
    ylabel('VSWR');
    set(gca, 'FontSize', 12);
    legend('VSWR', 'VSWR = 2 Threshold', 'Location', 'best');
    
    saveas(v_fig, fullfile(cfg.results_dir, sprintf('%s_vswr.png', prefix)));
    close(v_fig);
    
    % Smith Chart
    if license('test', 'RF_Toolbox') && exist('smithplot', 'file')
        s_fig = figure('Visible', 'off', 'Position', [100, 100, 800, 800]);
        
        % Calculate gamma
        gamma = 10.^(results.S11/20) .* exp(1j * angle(results.Z - cfg.Z0)); % Approximation if phase isn't exact
        % Better to just use reflection coefficient from Z if we have it
        gamma = (results.Z - cfg.Z0) ./ (results.Z + cfg.Z0);
        
        smithplot(results.freq, gamma, 'LineWidth', 2);
        title(sprintf('Smith Chart - %s', prefix));
        saveas(s_fig, fullfile(cfg.results_dir, sprintf('%s_smith.png', prefix)));
        close(s_fig);
    end
end
