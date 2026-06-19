%% STARTUP  Initialize MATLAB paths and environment for NMPC Overhead Crane project
%
% This script automatically sets up the MATLAB search path to include all
% project source directories.
%
% Usage:
%   startup         
%
% Path additions:
%   - src/           (all model, control, estimation, visualization functions)
%   - tasks/         (project task files)
%   - data/          (simulation results and data)
%   - docs/          (documentation)

% Get the project root directory
projectRoot = fileparts(mfilename('fullpath'));

% Define subdirectories to add to path
pathFolders = {
    'src'
    'src/config'
    'src/models'
    'src/control'
    'src/estimation'
    'src/simulation'
    'src/visualization'
    'tasks'
    'provided'
    'data'
};

% Add all folders to MATLAB path
for i = 1:length(pathFolders)
    folderPath = fullfile(projectRoot, pathFolders{i});
    if isdir(folderPath)
        addpath(folderPath);
        fprintf('[startup] Added: %s\n', pathFolders{i});
    else
        fprintf('[startup] Warning: %s not found\n', pathFolders{i});
    end
end

% Display project info
fprintf('\n');
fprintf('----------------------------------\n');
fprintf('  NMPC Overhead Crane Project\n');
fprintf('----------------------------------\n');
fprintf('  Root: %s\n', projectRoot);
fprintf('  Date: %s\n', datetime('now'));
fprintf('----------------------------------\n\n');

% Save current directory
cd(projectRoot);
