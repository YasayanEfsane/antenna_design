function results = simulate_patch_antenna(ant, cfg)
% SIMULATE_PATCH_ANTENNA Simulates the patch antenna using full-wave EM.
%   results = SIMULATE_PATCH_ANTENNA(ant, cfg)
%   Inputs:
%       ant - Antenna object (from build_patch_antenna)
%       cfg - Configuration structure
%   Outputs:
%       results - Structure containing simulated parameters (S11, Z, freq)

    results.freq = cfg.freq_vector;
    
    % Handle case where Antenna Toolbox is missing (dummy mode)
    if isstruct(ant) && isfield(ant, 'type') && strcmp(ant.type, 'Dummy_Patch')
        disp('Running dummy simulation...');
        results.S11 = zeros(size(cfg.freq_vector));
        results.Z = 50 * ones(size(cfg.freq_vector));
        results.vswr = ones(size(cfg.freq_vector));
        results.f_res = cfg.f0;
        results.min_S11 = 0;
        return;
    end
    
    disp('Simulating impedance and S-parameters...');
    
    try
        % 1. Calculate Impedance
        results.Z = impedance(ant, cfg.freq_vector);
        
        % 2. Calculate S-parameters
        S = sparameters(ant, cfg.freq_vector, cfg.Z0);
        results.S11 = 20 * log10(abs(rfparam(S, 1, 1)));
        
        % 3. Calculate VSWR
        Gamma = abs(rfparam(S, 1, 1));
        results.vswr = (1 + Gamma) ./ max(1 - Gamma, eps);
        
        % Find resonance frequency (minimum S11)
        [results.min_S11, min_idx] = min(results.S11);
        results.f_res = cfg.freq_vector(min_idx);
        
        % Bandwidth is calculated externally, but we'll include pattern if needed
        disp('Calculating 3D Pattern at center frequency...');
        [results.D_3d, results.az_3d, results.el_3d] = pattern(ant, cfg.f0);
        
        % Calculate Radiation Efficiency and Max Gain (if supported)
        % For patchMicrostrip, gain is often roughly directivity for low loss.
        % Let's get max directivity.
        results.max_gain = max(results.D_3d(:));
        
        try
            results.efficiency = efficiency(ant, cfg.f0);
        catch
            results.efficiency = NaN; % If API doesn't support it directly
        end
        
    catch ME
        warning('Simulation failed: %s', ME.message);
        results.S11 = zeros(size(cfg.freq_vector));
        results.Z = zeros(size(cfg.freq_vector));
        results.vswr = ones(size(cfg.freq_vector));
        results.f_res = NaN;
        results.min_S11 = NaN;
        results.max_gain = NaN;
        results.efficiency = NaN;
    end
end
