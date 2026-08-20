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
    
    % Create patch microstrip antenna based on feed type
    if isfield(cfg, 'feed_type') && strcmpi(cfg.feed_type, 'inset')
        % Microstrip line inset feed
        if ~isempty(which('patchMicrostripInsetfed'))
            ant = patchMicrostripInsetfed;
            ant.Length = dim.L;
            ant.Width = dim.W;
            ant.GroundPlaneLength = dim.L_gnd;
            ant.GroundPlaneWidth = dim.W_gnd;
            ant.Substrate = d;
            ant.StripLineWidth = W_feed;
            
            % Feed location calculations for inset
            if nargin < 4
                feed_offset = dim.L/4;
            end
            % Inset distance
            ant.NotchLength = feed_offset;
            ant.NotchWidth = W_feed * 1.5; % clearance around line
        else
            warning('patchMicrostripInsetfed not found. Falling back to probe feed.');
            ant = patchMicrostrip;
            ant.Length = dim.L;
            ant.Width = dim.W;
            ant.GroundPlaneLength = dim.L_gnd;
            ant.GroundPlaneWidth = dim.W_gnd;
            ant.Substrate = d;
            
            if nargin < 4
                feed_offset = 0;
            end
            ant.FeedOffset = [feed_offset, 0];
        end
    else
        % Coaxial probe feed (default)
        ant = patchMicrostrip;
        ant.Length = dim.L;
        ant.Width = dim.W;
        ant.GroundPlaneLength = dim.L_gnd;
        ant.GroundPlaneWidth = dim.W_gnd;
        ant.Substrate = d;
        
        if nargin < 4
            feed_offset = 0;
        end
        % For probe feed, FeedOffset dictates where the probe hits the patch
        ant.FeedOffset = [feed_offset, 0];
    end
    
    % Set conductor properties
    
    % Try to mesh it with lambda/10 for accuracy
    try
        lambda = 3e8 / cfg.f0;
        mesh(ant, 'MaxEdgeLength', lambda / cfg.mesh_lambda_ratio);
    catch ME
        warning('Mesh generation failed: %s', ME.message);
    end
end
