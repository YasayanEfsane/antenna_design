function ant = build_patch_antenna(cfg, dim, W_feed, feed_offset)
% BUILD_PATCH_ANTENNA Creates the patchMicrostrip object.
%   ant = BUILD_PATCH_ANTENNA(cfg, dim, W_feed, feed_offset)
%   Inputs:
%       cfg - Configuration struct
%       dim - Structure containing L, W, L_gnd, W_gnd
%       W_feed - Feed width
%       feed_offset - Feed offset from center along x-axis (meters)
%   Outputs:
%       ant - Created antenna object

    % Check if Antenna Toolbox is available
    if ~license('test', 'Antenna_Toolbox') || isempty(which('patchMicrostrip'))
        warning('Antenna Toolbox not found. Returning a dummy struct.');
        ant = struct('type', 'Dummy_Patch', 'L', dim.L, 'W', dim.W);
        return;
    end
    
    % Define dielectric material
    d = dielectric('FR4');
    d.EpsilonR = cfg.epsilon_r;
    d.LossTangent = cfg.tan_delta;
    d.Thickness = cfg.h;
    
    % Create patch microstrip antenna
    ant = patchMicrostrip;
    ant.Length = dim.L;
    ant.Width = dim.W;
    ant.GroundPlaneLength = dim.L_gnd;
    ant.GroundPlaneWidth = dim.W_gnd;
    ant.Substrate = d;
    
    % Set conductor properties
    ant.Conductor = metal('Copper');
    ant.Conductor.Thickness = cfg.cond_thickness;
    ant.Conductor.Conductivity = cfg.sigma_copper;
    
    % Determine feed position
    % For patchMicrostrip in MATLAB, FeedOffset is a 1x2 vector [x-offset, y-offset]
    % Origin is at the center of the patch.
    if nargin < 4
        feed_offset = 0;
    end
    ant.FeedOffset = [feed_offset, 0];
    
    % Try to mesh it with lambda/10 for accuracy
    try
        lambda = 3e8 / cfg.f0;
        mesh(ant, 'MaxEdgeLength', lambda / cfg.mesh_lambda_ratio);
    catch ME
        warning('Mesh generation failed: %s', ME.message);
    end
end
