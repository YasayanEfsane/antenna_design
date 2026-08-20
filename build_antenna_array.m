function array_ant = build_antenna_array(single_element, cfg, num_rows, num_cols)
% BUILD_ANTENNA_ARRAY Creates a planar array from a single patch element.
%   array_ant = BUILD_ANTENNA_ARRAY(single_element, cfg, rows, cols)
%   Inputs:
%       single_element - The optimized patchMicrostrip object
%       cfg - Configuration struct
%       num_rows - Number of rows in the array
%       num_cols - Number of columns in the array
%   Outputs:
%       array_ant - Created rectangularArray object

    if ~license('test', 'Antenna_Toolbox') || isempty(which('rectangularArray'))
        warning('Antenna Toolbox not found. Cannot build array.');
        array_ant = [];
        return;
    end
    
    % Free space wavelength
    lambda = 3e8 / cfg.f0;
    
    % Ensure the element ground plane is large enough for the array
    single_element.GroundPlaneLength = (num_rows) * lambda;
    single_element.GroundPlaneWidth = (num_cols) * lambda;
    
    % Create the rectangular array
    array_ant = rectangularArray;
    array_ant.Element = single_element;
    array_ant.Size = [num_rows, num_cols];
    
    % Typical spacing is lambda/2 to avoid grating lobes
    % Distance between element centers
    array_ant.RowSpacing = lambda / 2;
    array_ant.ColumnSpacing = lambda / 2;
end
