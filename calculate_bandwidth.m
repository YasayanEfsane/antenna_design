function bw_results = calculate_bandwidth(freq_vector, S11, threshold_dB)
% CALCULATE_BANDWIDTH Safely calculates the impedance bandwidth.
%   bw_results = CALCULATE_BANDWIDTH(freq_vector, S11, threshold_dB)
%   Inputs:
%       freq_vector - Frequency array (Hz)
%       S11 - S11 values array (dB)
%       threshold_dB - Bandwidth threshold (typically -10)
%   Outputs:
%       bw_results - Structure containing f_lower, f_upper, absolute_BW, fractional_BW

    if nargin < 3
        threshold_dB = -10;
    end
    
    bw_results.f_lower = NaN;
    bw_results.f_upper = NaN;
    bw_results.absolute_BW = NaN;
    bw_results.fractional_BW = NaN;
    
    % Find indices where S11 is below threshold
    idx_below = find(S11 <= threshold_dB);
    
    if isempty(idx_below)
        % No bandwidth found
        return;
    end
    
    % Find the continuous block around the minimum S11
    [~, min_idx] = min(S11);
    
    if min_idx == 1 || min_idx == length(S11)
        % Minimum is at the edge, bandwidth might be inaccurate
    end
    
    % Trace left to find lower cutoff
    idx = min_idx;
    while idx > 1 && S11(idx) <= threshold_dB
        idx = idx - 1;
    end
    % Interpolate for better accuracy
    if idx > 0 && idx < length(S11) && S11(idx+1) <= threshold_dB
        % Linear interpolation: f = f1 + (f2-f1)*(t-S1)/(S2-S1)
        bw_results.f_lower = freq_vector(idx) + (freq_vector(idx+1) - freq_vector(idx)) * ...
            (threshold_dB - S11(idx)) / (S11(idx+1) - S11(idx));
    else
        bw_results.f_lower = freq_vector(max(1, idx));
    end
    
    % Trace right to find upper cutoff
    idx = min_idx;
    while idx < length(S11) && S11(idx) <= threshold_dB
        idx = idx + 1;
    end
    if idx <= length(S11) && idx > 1 && S11(idx-1) <= threshold_dB
        bw_results.f_upper = freq_vector(idx-1) + (freq_vector(idx) - freq_vector(idx-1)) * ...
            (threshold_dB - S11(idx-1)) / (S11(idx) - S11(idx-1));
    else
        bw_results.f_upper = freq_vector(min(length(S11), idx));
    end
    
    if ~isnan(bw_results.f_lower) && ~isnan(bw_results.f_upper)
        bw_results.absolute_BW = bw_results.f_upper - bw_results.f_lower;
        f_center = (bw_results.f_upper + bw_results.f_lower) / 2;
        bw_results.fractional_BW = (bw_results.absolute_BW / f_center) * 100;
    end
end
