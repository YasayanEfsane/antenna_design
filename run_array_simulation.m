% RUN_ARRAY_SIMULATION Demonstrates building and simulating a 2x2 Array
% of the optimized 2.45 GHz Microstrip Patch Antenna using Pattern Multiplication.

clear; close all; clc;

disp('======================================================');
disp(' 2.45 GHz Microstrip Patch 2x2 Antenna Array ');
disp('======================================================');

disp('1. Loading configuration and previous optimized results...');
cfg = config();
try
    load(fullfile(cfg.results_dir, 'all_results.mat'), 'dim_opt', 'res_opt');
catch
    error('Optimized results not found. Please run main.m first.');
end

% Extract the 3D pattern of the single element from previous results
% Note: res_opt contains D_3d (Directivity), az_3d, el_3d.
if ~isfield(res_opt, 'D_3d')
    error('3D pattern data not found in results. Run main.m to generate it.');
end

single_gain = res_opt.max_gain;
fprintf('Single Element Max Gain : %.2f dBi\n', single_gain);

disp('2. Calculating Array Factor for 2x2 Array...');
% Array parameters
num_rows = 2;
num_cols = 2;
lambda = 3e8 / cfg.f0;
dx = lambda / 2;
dy = lambda / 2;

% Create a meshgrid for Azimuth (-180:180) and Elevation (-90:90)
az = -180:2:180;
el = -90:2:90;
[AZ, EL] = meshgrid(az, el);

% Convert to radians for calculation
AZ_rad = deg2rad(AZ);
EL_rad = deg2rad(EL);

% Calculate Array Factor (AF)
% Using standard phased array theory for planar arrays (broadside)
k = 2 * pi / lambda;
psi_x = k * dx * cos(EL_rad) .* cos(AZ_rad);
psi_y = k * dy * cos(EL_rad) .* sin(AZ_rad);

AF_x = sin(num_rows * psi_x / 2) ./ (num_rows * sin(psi_x / 2 + eps));
AF_y = sin(num_cols * psi_y / 2) ./ (num_cols * sin(psi_y / 2 + eps));

AF = abs(AF_x .* AF_y);
% Array directivity increases by 10*log10(N) where N is total elements (4).
AF_dB = 20 * log10(AF + eps) + 10 * log10(num_rows * num_cols); 

disp('3. Applying Pattern Multiplication...');
% Interpolate the single element pattern to our grid
% Usually res_opt.az_3d and res_opt.el_3d are vectors, and D_3d is a matrix.
% We need to make sure the dimensions match.
if isvector(res_opt.az_3d)
    [AZ_orig, EL_orig] = meshgrid(res_opt.az_3d, res_opt.el_3d);
    D_single_interp = interp2(AZ_orig, EL_orig, res_opt.D_3d, AZ, EL, 'linear', -40);
else
    D_single_interp = res_opt.D_3d; % If it's already matching
end

% Total Directivity = Single Element Directivity + Array Factor
D_total = D_single_interp + AF_dB;

% Mask values below a certain threshold for better plotting
D_total(D_total < -40) = -40;
array_gain = max(D_total(:));

disp('4. Plotting 3D Radiation Pattern for the Array...');
f_pat = figure('Visible', 'off');
surf(AZ, EL, D_total, 'EdgeColor', 'none');
title('2x2 Array 3D Radiation Pattern (Pattern Multiplication)');
xlabel('Azimuth (deg)');
ylabel('Elevation (deg)');
zlabel('Directivity (dBi)');
colorbar;
view(45, 30);
saveas(f_pat, fullfile(cfg.results_dir, 'array_pattern.png'));
close(f_pat);

fprintf('------------------------------------------------------\n');
fprintf(' 2x2 Array Max Gain      : %.2f dBi\n', array_gain);
fprintf(' Gain Improvement        : +%.2f dB\n', array_gain - single_gain);
fprintf('------------------------------------------------------\n');

disp('Array simulation complete using Pattern Multiplication Principle.');
disp('Check results/array_pattern.png for the radiation pattern.');
