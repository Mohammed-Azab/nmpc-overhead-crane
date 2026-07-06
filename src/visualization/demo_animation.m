%% demo_animation
% Open-loop demo

clear; clc; close all;

addProjectPaths;
params;
output_config;        % save / gif switches
T_s = 0.05;           % finer sample time for a smooth animation
loadSystem;

%% Time grid
t_end = 25;
t = 0:T_s:t_end;
N = numel(t);

%% Input program: balanced "move and stop" pulse pairs
Amp = 1.5;   
tau = 1.0;            % pulse duration [s]
u = zeros(1, N);
u(t >= 1     & t < 1+tau)   =  Amp;   % move right
u(t >= 1+tau & t < 1+2*tau) = -Amp;
u(t >= 9     & t < 9+tau)   = -Amp;   % move back left
u(t >= 9+tau & t < 9+2*tau) =  Amp;

%% Simulate the non-linear crane with the shared one-step integrator
X = zeros(N, 4);      % [x_load, v_load, x_crane, v_crane]
for k = 1:N-1
    X(k+1,:) = stepF(X(k,:).', u(k)).';
end

%% Show with the shared plot + animation functions
res.t   = t;
res.X   = X;
res.u   = u;
res.ref = zeros(1, N);

plotCraneResults(res, ...
    'Title', 'Crane demo: open-loop swing', ...
    'Animate', true, ...
    'CableLength', 2, ...
    'Speed', 1, ...
    'Save', save_plots, 'SaveFormat', save_fmt, 'SaveDir', save_dir, ...
    'SaveAnim', save_anim, 'GifStride', gif_stride, 'GifScale', gif_scale);
