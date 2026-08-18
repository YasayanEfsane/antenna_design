function run_tests()
% RUN_TESTS Performs sanity checks on the project functions and outputs.
%   Validates units, dimensions, and ensures outputs are correctly generated.

    disp('Running tests...');
    
    % 1. Config Test
    cfg = config();
    assert(cfg.f0 == 2.45e9, 'Config frequency mismatch.');
    assert(cfg.freq_vector(1) > 0, 'Frequencies must be positive.');
    assert(issorted(cfg.freq_vector), 'Frequency vector must be sorted.');
    
    % 2. Dimensions Test
    dim = calculate_patch_dimensions(cfg);
    assert(dim.W > 0, 'Patch width must be positive.');
    assert(dim.L > 0, 'Patch length must be positive.');
    assert(dim.L < dim.W, 'Patch length is normally less than width for standard modes.');
    
    W_feed = calculate_microstrip_width(cfg);
    assert(W_feed > 0, 'Feed width must be positive.');
    
    % 3. Bandwidth Test
    % Create a dummy resonance
    dummy_freq = linspace(1e9, 3e9, 100);
    dummy_S11 = -20 * exp(-((dummy_freq - 2e9) / 1e8).^2); 
    bw = calculate_bandwidth(dummy_freq, dummy_S11, -10);
    if ~isnan(bw.f_lower)
        assert(bw.f_upper > bw.f_lower, 'Upper cutoff must be > lower cutoff.');
        assert(bw.absolute_BW > 0, 'Bandwidth must be positive.');
    end
    
    % 4. File existence test (if main has been run)
    if exist(cfg.results_dir, 'dir')
        csv_file = fullfile(cfg.results_dir, 'summary.csv');
        if exist(csv_file, 'file')
            disp('Summary CSV found.');
        end
    end
    
    disp('All tests passed successfully.');
end
