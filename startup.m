%% STARTUP: Initialize MATLAB paths and environment

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'src', 'common'));  % make addProjectPaths visible
addProjectPaths();

fprintf('All Set!\n');
