%% STARTUP: Initialize MATLAB paths and environment

projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(fullfile(projectRoot, 'tasks'));
addpath(genpath(fullfile(projectRoot, 'provided')));
if isfolder(fullfile(projectRoot, 'data'))
    addpath(genpath(fullfile(projectRoot, 'data')));
end

fprintf('All Set!\n');
