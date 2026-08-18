% 2.45 GHz Microstrip Patch Antenna Design, Simulation, and Optimization
% Main Execution Script

clear; close all; clc;

disp('======================================================');
disp(' 2.45 GHz Microstrip Patch Antenna Project');
disp('======================================================');

% 1. Load Configuration
disp('1. Loading configuration...');
cfg = config();

% 2. Analytical Calculations
disp('2. Calculating analytical dimensions...');
dim_ana = calculate_patch_dimensions(cfg);
W_feed = calculate_microstrip_width(cfg);

fprintf('Analytical Patch Length: %.2f mm\n', dim_ana.L * 1e3);
fprintf('Analytical Patch Width: %.2f mm\n', dim_ana.W * 1e3);

% 3. Analytical Simulation (Initial Design)
disp('3. Simulating analytical design...');
ant_ana = build_patch_antenna(cfg, dim_ana, W_feed, dim_ana.inset_dist);
res_ana = simulate_patch_antenna(ant_ana, cfg);
bw_ana = calculate_bandwidth(cfg.freq_vector, res_ana.S11, -10);

disp('Plotting initial results...');
plot_results(cfg, res_ana, 'analytical');

% 4. Optimization
disp('4. Optimizing antenna dimensions...');
[dim_opt, feed_offset_opt] = optimize_patch_antenna(cfg, dim_ana, W_feed);

fprintf('Optimized Patch Length: %.2f mm\n', dim_opt.L * 1e3);
fprintf('Optimized Patch Width: %.2f mm\n', dim_opt.W * 1e3);

% 5. Optimized Simulation
disp('5. Simulating optimized design...');
ant_opt = build_patch_antenna(cfg, dim_opt, W_feed, feed_offset_opt);
res_opt = simulate_patch_antenna(ant_opt, cfg);
bw_opt = calculate_bandwidth(cfg.freq_vector, res_opt.S11, -10);

disp('Plotting optimized results...');
plot_results(cfg, res_opt, 'optimized');

% 6. Export Results
disp('6. Exporting numerical results...');
export_results(cfg, dim_ana, dim_opt, res_ana, res_opt, bw_ana, bw_opt);

% 7. Generate Report
disp('7. Generating markdown report...');
generate_report(cfg);

disp('======================================================');
disp(' Project Execution Complete.');
disp(' Please check the "results" and "report" directories.');
disp('======================================================');
