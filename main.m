clear; clf; clc;

if isempty(which('state_definition'))
	warning('Paths not initialized. Run startup.m first.');
	startup
end

%% Load configuration
run params.m

% Experiment parameters
load_sys
Hsim   = ceil(T_max/T_s);
repeat = 3;
t_lin  = linspace(0, T_s*(Hsim-1), Hsim);

[positionLoad, steps_size, speedCrane] = simulateCran_multi(T_s, Hsim, repeat);

%% Run tasks
% task1_approximate_nonlinearity
% task2_nmpc
% task3_observer_ekf
