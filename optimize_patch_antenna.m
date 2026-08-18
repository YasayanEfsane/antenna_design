function [opt_dim, opt_feed_offset] = optimize_patch_antenna(cfg, initial_dim, W_feed)
% OPTIMIZE_PATCH_ANTENNA Optimizes patch dimensions for 2.45 GHz resonance.
%   Uses Optimization Toolbox if available, else does a fine sweep.

    if ~license('test', 'Optimization_Toolbox') || isempty(which('fminsearch'))
        warning('Optimization Toolbox not available. Returning initial dimensions.');
        opt_dim = initial_dim;
        opt_feed_offset = initial_dim.L / 4; % fallback
        return;
    end
    
    disp('Starting Optimization...');
    
    % Optimization variables: [Delta_L_factor, Delta_W_factor, Feed_offset_factor]
    % Factors around 1.0 to keep scaling balanced
    x0 = [1.0, 1.0, 0.25];
    
    % Objective function wrapper
    obj_fun = @(x) cost_function(x, cfg, initial_dim, W_feed);
    
    % Options for fminsearch
    options = optimset('Display', 'iter', 'TolX', 1e-3, 'TolFun', 1e-1, 'MaxIter', 15);
    
    try
        x_opt = fminsearch(obj_fun, x0, options);
    catch ME
        warning('Optimization failed: %s', ME.message);
        x_opt = x0;
    end
    
    % Reconstruct optimal dimensions
    opt_dim = initial_dim;
    opt_dim.L = initial_dim.L * x_opt(1);
    opt_dim.W = initial_dim.W * x_opt(2);
    % Update ground plane based on new L and W
    opt_dim.L_gnd = opt_dim.L + 6 * cfg.h;
    opt_dim.W_gnd = opt_dim.W + 6 * cfg.h;
    
    opt_feed_offset = opt_dim.L * x_opt(3);
    
    disp('Optimization Complete.');
end

function cost = cost_function(x, cfg, dim, W_feed)
    % Extract variables safely
    L_scale = max(0.5, min(x(1), 1.5));
    W_scale = max(0.5, min(x(2), 1.5));
    feed_frac = max(-0.5, min(x(3), 0.5));
    
    current_dim = dim;
    current_dim.L = dim.L * L_scale;
    current_dim.W = dim.W * W_scale;
    current_dim.L_gnd = current_dim.L + 6 * cfg.h;
    current_dim.W_gnd = current_dim.W + 6 * cfg.h;
    
    feed_offset = current_dim.L * feed_frac;
    
    % Build and simulate (coarse frequency vector for speed)
    fast_freq = linspace(cfg.f0 - 100e6, cfg.f0 + 100e6, 11);
    
    ant = build_patch_antenna(cfg, current_dim, W_feed, feed_offset);
    if isstruct(ant)
        cost = 1e6; return;
    end
    
    try
        S = sparameters(ant, fast_freq, cfg.Z0);
        S11 = 20 * log10(abs(rfparam(S, 1, 1)));
        
        [min_S11, min_idx] = min(S11);
        f_res = fast_freq(min_idx);
        
        % S11 at target frequency
        % Interpolate if f0 is not exactly in fast_freq
        S11_target = interp1(fast_freq, S11, cfg.f0, 'linear', 0);
        
        % Cost calculation
        freq_error = abs(f_res - cfg.f0) / 1e6; % Error in MHz
        
        % Match penalty: if S11_target > -10, heavily penalize. 
        % We want S11 at 2.45 GHz to be as low as possible.
        match_penalty = max(0, S11_target + 10)^2;
        if S11_target < -10
            match_penalty = S11_target; % Reward being very matched
        end
        
        cost = cfg.w1 * freq_error + cfg.w2 * match_penalty;
    catch
        cost = 1e6; % High penalty for failed sim
    end
end
