function cfg = config()
% CONFIG Returns a structure with all configuration parameters for the 2.45 GHz Antenna Project.
%   Provides frequency, material properties, simulation settings, and optimization weights.

    % Frequency Settings (SI Units)
    cfg.f0 = 2.45e9;                % Target resonance frequency (Hz)
    cfg.f_start = 1.8e9;            % Start frequency for sweep (Hz)
    cfg.f_stop = 3.0e9;             % Stop frequency for sweep (Hz)
    cfg.f_step = 5e6;               % Frequency step for sweep (Hz)
    cfg.freq_vector = cfg.f_start:cfg.f_step:cfg.f_stop; % Frequency vector

    % Substrate Properties (FR-4)
    cfg.epsilon_r = 4.4;            % Relative permittivity
    cfg.h = 1.6e-3;                 % Substrate thickness (m)
    cfg.tan_delta = 0.02;           % Loss tangent

    % Conductor Properties (Copper)
    cfg.cond_thickness = 35e-6;     % Copper thickness (m)
    cfg.sigma_copper = 5.8e7;       % Conductivity of copper (S/m)

    % Feed properties
    cfg.Z0 = 50;                    % Target characteristic impedance (Ohms)
    cfg.feed_type = 'probe';        % 'probe' for coaxial feed, 'inset' for microstrip line feed

    % Simulation Settings
    cfg.mesh_lambda_ratio = 10;     % Mesh size = lambda / mesh_lambda_ratio

    % Optimization Settings
    cfg.w1 = 1.0;                   % Weight for frequency error
    cfg.w2 = 0.5;                   % Weight for S11 matching penalty
    cfg.w3 = 0.0;                   % Weight for size penalty (optional)
    
    % Paths
    cfg.results_dir = 'results';
    cfg.report_dir = 'report';
end
