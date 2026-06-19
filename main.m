%% MPC Project

clear; clf; clc;

%% NMPC Overhead Crane - Main Project Entry Point
%
% Make sure to run startup.m first to set up paths.
%
% Usage:
%   startup          % Initialize paths (run once per session)
%   main             % Run this script to execute tasks

% Verify paths are initialized
if isempty(which('state_definition'))
	warning('Paths not initialized. Run startup.m first.');
	startup
end

%% Load configuration
% Experiment parameters
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
