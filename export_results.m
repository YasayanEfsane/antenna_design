function export_results(cfg, dim_ana, dim_opt, res_ana, res_opt, bw_ana, bw_opt)
% EXPORT_RESULTS Saves numerical results to CSV and MAT files.

    if ~exist(cfg.results_dir, 'dir')
        mkdir(cfg.results_dir);
    end
    
    % Save all variables to MAT file
    save(fullfile(cfg.results_dir, 'all_results.mat'), 'cfg', 'dim_ana', 'dim_opt', 'res_ana', 'res_opt', 'bw_ana', 'bw_opt');
    
    % Create a summary table
    Parameter = {
        'Analytical Patch Length (mm)';
        'Optimized Patch Length (mm)';
        'Analytical Patch Width (mm)';
        'Optimized Patch Width (mm)';
        'Feed Offset (mm)';
        'Resonance Frequency (GHz)';
        'S11 at 2.45 GHz (dB)';
        'Minimum S11 (dB)';
        'VSWR at Resonance';
        'Lower Cutoff Freq (GHz)';
        'Upper Cutoff Freq (GHz)';
        'Bandwidth (MHz)';
        'Fractional Bandwidth (%)';
        'Max Gain (dBi)';
        'Radiation Efficiency'
    };

    % Helper to format values
    fmt = @(x) sprintf('%.4f', x);
    
    Value = {
        fmt(dim_ana.L * 1e3);
        fmt(dim_opt.L * 1e3);
        fmt(dim_ana.W * 1e3);
        fmt(dim_opt.W * 1e3);
        fmt(dim_opt.inset_dist * 1e3); % Assuming inset_dist was updated or we use opt_feed_offset if passed.
        fmt(res_opt.f_res / 1e9);
        fmt(interp1(res_opt.freq, res_opt.S11, cfg.f0));
        fmt(res_opt.min_S11);
        fmt(interp1(res_opt.freq, res_opt.vswr, res_opt.f_res));
        fmt(bw_opt.f_lower / 1e9);
        fmt(bw_opt.f_upper / 1e9);
        fmt(bw_opt.absolute_BW / 1e6);
        fmt(bw_opt.fractional_BW);
        fmt(res_opt.max_gain);
        fmt(res_opt.efficiency)
    };
    
    T = table(Parameter, Value);
    writetable(T, fullfile(cfg.results_dir, 'summary.csv'));
    
    disp('Results exported to CSV and MAT files.');
end
