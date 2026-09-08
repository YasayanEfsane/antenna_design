% PLOT_CURRENT_DISTRIBUTION Calculates and visualizes the surface current
% distribution of the optimized patch antenna at its resonance frequency.

clear; close all; clc;

disp('======================================================');
disp(' Surface Current Distribution Analysis ');
disp('======================================================');

% 1. Load Configuration and Optimized Dimensions
disp('1. Loading configuration and previous optimized results...');
cfg = config();
try
    load(fullfile(cfg.results_dir, 'all_results.mat'), 'dim_opt', 'res_opt');
catch
    error('Optimized results not found. Please run main.m first.');
end

% 2. Rebuild the optimized patch element
disp('2. Rebuilding the single optimized patch element...');
W_feed = calculate_microstrip_width(cfg);
ant_opt = build_patch_antenna(cfg, dim_opt, W_feed, dim_opt.inset_dist);

% 3. Calculate and Plot Current Distribution
disp(['3. Calculating surface current at ', num2str(cfg.f0/1e9), ' GHz...']);
disp('   (This visualizes where the electromagnetic energy is concentrated)');

f_current = figure('Name', 'Surface Current Distribution', 'Position', [100, 100, 800, 600], 'Visible', 'off');
current(ant_opt, cfg.f0);
title(sprintf('Surface Current Distribution at %.2f GHz', cfg.f0/1e9));

% Save the plot
current_plot_path = fullfile(cfg.results_dir, 'current_distribution.png');
saveas(f_current, current_plot_path);
close(f_current);

disp('------------------------------------------------------');
disp(['Current distribution plot saved to: ', current_plot_path]);
disp('Observe the red areas (high current) mostly concentrated near the feed');
disp('and the edges parallel to the radiating slots.');
disp('======================================================');
