% EXPORT_TO_GERBER Exports the optimized patch antenna to Gerber format for physical PCB manufacturing.

clear; close all; clc;

disp('======================================================');
disp(' Exporting Antenna to Gerber Files ');
disp('======================================================');

cfg = config();
try
    load(fullfile(cfg.results_dir, 'all_results.mat'), 'dim_opt');
catch
    error('Optimized results not found. Please run main.m first.');
end

% Check if RF PCB Toolbox is available
if ~license('test', 'RF_PCB_Toolbox') || isempty(which('gerberWrite'))
    warning('RF PCB Toolbox is not installed. Gerber export requires this toolbox.');
    return;
end

% Build the optimized single element
W_feed = calculate_microstrip_width(cfg);
ant_opt = build_patch_antenna(cfg, dim_opt, W_feed, dim_opt.inset_dist);

% Define export directory
gerber_dir = fullfile(pwd, 'gerber_files');
if ~exist(gerber_dir, 'dir')
    mkdir(gerber_dir);
end

% Export to Gerber
try
    disp('Generating Gerber (RS-274X) and Excellon Drill files...');
    % We use gerberWrite to automatically generate the PCB manufacturing files
    gerberWrite(ant_opt, 'PatchAntenna_245GHz', 'Directory', gerber_dir);
    disp(['Success! Gerber files generated in: ', gerber_dir]);
    disp('You can now zip these files and send them to a PCB manufacturer (like JLCPCB, PCBWay, etc.).');
catch ME
    warning('Failed to generate Gerber files: %s', ME.message);
end
