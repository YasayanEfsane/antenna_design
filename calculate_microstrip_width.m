function W_feed = calculate_microstrip_width(cfg)
% CALCULATE_MICROSTRIP_WIDTH Calculates the width of a 50-ohm microstrip line.
%   W_feed = CALCULATE_MICROSTRIP_WIDTH(cfg)
%   Inputs:
%       cfg - Configuration struct containing h, epsilon_r, Z0
%   Outputs:
%       W_feed - Width of the microstrip line in meters.

    % Constants
    A = (cfg.Z0 / 60) * sqrt((cfg.epsilon_r + 1) / 2) + ((cfg.epsilon_r - 1) / (cfg.epsilon_r + 1)) * (0.23 + 0.11 / cfg.epsilon_r);
    B = 377 * pi / (2 * cfg.Z0 * sqrt(cfg.epsilon_r));
    
    % Determine W/h ratio using standard equations
    if A > 1.52
        % Narrow strip approximation W/h < 2
        W_h = (8 * exp(A)) / (exp(2 * A) - 2);
    else
        % Wide strip approximation W/h > 2
        W_h = (2 / pi) * (B - 1 - log(2 * B - 1) + ((cfg.epsilon_r - 1) / (2 * cfg.epsilon_r)) * (log(B - 1) + 0.39 - 0.61 / cfg.epsilon_r));
    end
    
    % Calculate physical width
    W_feed = W_h * cfg.h;
end
