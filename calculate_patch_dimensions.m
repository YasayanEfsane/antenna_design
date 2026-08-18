function dim = calculate_patch_dimensions(cfg)
% CALCULATE_PATCH_DIMENSIONS Calculates theoretical dimensions of a rectangular microstrip patch.
%   dim = CALCULATE_PATCH_DIMENSIONS(cfg) uses transmission line model equations.
%   Inputs:
%       cfg - Configuration structure containing f0, epsilon_r, h.
%   Outputs:
%       dim - Structure containing calculated dimensions (W, L, L_eff, epsilon_eff, delta_L, etc.) in meters.

    % Speed of light in vacuum (m/s)
    c0 = 299792458;
    
    % Free space wavelength (m)
    lambda_0 = c0 / cfg.f0;
    
    % 1. Patch Width (W)
    % Equation for efficient radiation: W = c0 / (2 * f0) * sqrt(2 / (epsilon_r + 1))
    dim.W = (c0 / (2 * cfg.f0)) * sqrt(2 / (cfg.epsilon_r + 1));
    
    % 2. Effective Dielectric Constant (epsilon_eff)
    % Accounts for fringing fields in air.
    dim.epsilon_eff = (cfg.epsilon_r + 1) / 2 + ((cfg.epsilon_r - 1) / 2) * (1 + 12 * (cfg.h / dim.W))^(-0.5);
    
    % 3. Fringing length extension (delta_L)
    % Due to fringing fields, the patch looks electrically larger.
    num = (dim.epsilon_eff + 0.3) * (dim.W / cfg.h + 0.264);
    den = (dim.epsilon_eff - 0.258) * (dim.W / cfg.h + 0.8);
    dim.delta_L = 0.412 * cfg.h * (num / den);
    
    % 4. Effective Length (L_eff)
    % Half-wavelength in the dielectric medium
    dim.L_eff = c0 / (2 * cfg.f0 * sqrt(dim.epsilon_eff));
    
    % 5. Actual Patch Length (L)
    % Subtract fringing extensions from both sides
    dim.L = dim.L_eff - 2 * dim.delta_L;
    
    % 6. Ground Plane Dimensions
    % Rule of thumb: add 6*h to patch dimensions to avoid diffraction from edges
    dim.L_gnd = dim.L + 6 * cfg.h;
    dim.W_gnd = dim.W + 6 * cfg.h;
    
    % 7. Inset Feed Distance (approximate)
    % Estimate for a 50 ohm inset point
    dim.inset_dist = dim.L / 4; % Starting guess
    
    % Ensure L < W constraint is met, which is standard for efficient radiation.
    if dim.L >= dim.W
        warning('Calculated patch length is greater than or equal to width. The antenna may not radiate efficiently.');
    end
end
