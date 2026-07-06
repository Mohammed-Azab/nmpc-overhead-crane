%% Params File

%% Experiment
T_max = 100;       % experiment stop time [s]
T_s   = 0.15;      % sample time [s]  (can be changed)


%% State Space Model
% x_dot = A x + [0;0;0;g(u)],  y = C x
A = [ 0    1    0    0;
     -3  -0.1   3   0.1;
      0    0    0    1;
      0    0    0  -0.2]; 

C = [1 0 0 0];     

%% Input non-linearity fallback 
% when RBF is NOT available
g_fallback    = @(u) (20/pi) .* atan((pi/20) .* u);
dgdu_fallback = @(u) 1 ./ ((pi^2 .* u.^2)/400 + 1);

%% RBF identification (Task 1)
rbf_repeat       = 100; 
rbf_N            = 15;    % number of Gaussian centers
rbf_sigma_factor = 2.0;   % width = sigma_factor * center spacing

%% NMPC (Task 2)
Hp = 20;                 % prediction horizon
Hc = 5;                  % control horizon
Q  = diag([10 0 0 0]);   % state weights (track load position)
R  = 0.1;                % input weight
u_min  = -5;   u_max  = 5;    % input limits
du_min = -6;   du_max = 6;    % input rate limits
x1_min = -50;  x1_max = 50;   % load position limits

%% EKF (Task 3)
ekf_Qc = diag([1e-3 1e-3 1e-3 1e-2]);  % process noise covariance
ekf_Rm = 1e-2;                         % measurement noise covariance
ekf_P0 = eye(4);                       % initial state covariance

%% Simulation scenario 
%  0 -> 5 -> 0
sim_t_end = 30;
sim_hold0 = 5;     % hold at 0 until t = 5 s
sim_move  = 5;     % target position
sim_back  = 20;    % return to 0 at t = 20 s


%% Notes
% A(4,4) = -friction