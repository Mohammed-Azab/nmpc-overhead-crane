%% MPC Project - Final Challenge: Bringing the Crane Under Control
% Top-level entry script. Run the tasks in order.
%
% Required toolboxes:
%   - Symbolic Math Toolbox
%   - Control System Toolbox
%   - Model Predictive Control Toolbox

clear; clf; clc;

% Add project folders to the path
addpath('tasks');
addpath('functions');
addpath('provided');

%% Experiment parameters
T_max  = 100;            % stop time for Patrick's experiment
T_s    = 0.15;           % sample time for Patrick's experiment (can be changed)
Hsim   = ceil(T_max/T_s);
repeat = 3;
t_lin  = linspace(0, T_s*(Hsim-1), Hsim);

% [positionLoad, steps_size, speedCrane] = simulateCran_multi(T_s, Hsim, repeat); % load System

%% Run tasks
% task1_approximate_nonlinearity
% task2_nmpc
% task3_observer_ekf
