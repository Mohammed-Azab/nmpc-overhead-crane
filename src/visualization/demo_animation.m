%% demo_animation
% Generates a sample state trajectory from Patrick's linear model

clear; clc; close all;
%addpath('functions');

%% Sample time and Patrick's linear model
T_s   = 0.05;              
t_end = 25;
t = 0:T_s:t_end;
N = numel(t);

A = [ 0     1     0     0  ;
     -3   -0.1    3    0.1 ;
      0     0     0     1  ;
      0     0     0   -0.2];
B = [0; 0; 0; 1];           

% Discretize
sysd = c2d(ss(A, B, eye(4), 0), T_s);
Ad = sysd.A;  Bd = sysd.B;

%% Input program: balanced "move and stop" maneuvers
Amp = 1.5;                  % pulse amplitude
tau = 1.0;                  % pulse duration [s]
u = zeros(1, N);

% Dummy movement:
% Each move is an equal accelerate/decelerate pulse pair
% move right 
u(t >= 1     & t < 1+tau)   =  Amp;
u(t >= 1+tau & t < 1+2*tau) = -Amp;
% move back left
u(t >= 9     & t < 9+tau)   = -Amp;
u(t >= 9+tau & t < 9+2*tau) =  Amp;

%% Simulate
X = zeros(N, 4);            % [x_load, v_load, x_crane, v_crane]
for k = 1:N-1
    X(k+1,:) = (Ad*X(k,:).' + Bd*u(k)).';
end

% Target line
y_ref = zeros(1, N);

%% One window, two tabs: animation + signal plots
fig = figure('Color','w','Name','Crane demo', 'Position',[80 80 1150 700]);
tg  = uitabgroup(fig);

tabAnim  = uitab(tg, 'Title', 'Animation');
tabPlots = uitab(tg, 'Title', 'Signals');

% Animation
axAnim = axes('Parent', tabAnim);
animateCrane(X, T_s, ...
    'CableLength', 2, ...
    'Speed', 1, ...
    'Trail', true, ...
    'Ref', y_ref, ...
    'Input', u, ...
    'Parent', axAnim, ...
    'Title', 'Crane demo: open-loop swing');

% Signal plots
ax1 = subplot(3,1,1,'Parent',tabPlots);
plot(ax1, t, X(:,1), 'LineWidth', 1.5); hold(ax1,'on');
plot(ax1, t, X(:,3), '--', 'LineWidth', 1.5); grid(ax1,'on');
legend(ax1, 'x_{load}', 'x_{crane}', 'Location', 'best');
ylabel(ax1, 'position [m]'); title(ax1, 'Positions');

ax2 = subplot(3,1,2,'Parent',tabPlots);
plot(ax2, t, X(:,2), 'LineWidth', 1.5); hold(ax2,'on');
plot(ax2, t, X(:,4), '--', 'LineWidth', 1.5); grid(ax2,'on');
legend(ax2, 'v_{load}', 'v_{crane}', 'Location', 'best');
ylabel(ax2, 'velocity [m/s]'); title(ax2, 'Velocities');

ax3 = subplot(3,1,3,'Parent',tabPlots);
stairs(ax3, t, u, 'LineWidth', 1.5); grid(ax3,'on');
ylabel(ax3, 'input u'); xlabel(ax3, 'time [s]'); title(ax3, 'Command input');
