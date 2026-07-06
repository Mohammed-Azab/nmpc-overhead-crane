function root = addProjectPaths()
% addProjectPaths  Add all project folders to the MATLAB path.

    root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    addpath(genpath(fullfile(root, 'src')));
    addpath(fullfile(root, 'tasks'));
    addpath(genpath(fullfile(root, 'provided')));
    if isfolder(fullfile(root, 'data'))
        addpath(genpath(fullfile(root, 'data')));
    end
end
