%% Task 2 - Crane with NMPC
% In day-to-day operation only the load position is measured, so y = x_load.
%
% Remark: If no function was found in Task 1, use
%   g(u)      = (20/pi) * atan((pi/20)*u)
%   dg(u)/du  = ( (pi^2 * u^2)/400 + 1 )^(-1)
% otherwise use the RBF function.

params;                     % load parameters
Hsim = ceil(T_max/T_s);

% NMPC model matrices
strct.A = A;
strct.B = B;
strct.C = C;

%% a) System analysis
% Examine controllability, observability and stability of the system.

% Controllability = ability to steer each state of system to desired val
% using a controller. Rank of Qc matrix = n dimensions of A = 4.
g = @(u) (20/pi())*atan((pi()/20)*u);
syms u

B_sym = [0; 0; 0; g(u)];    % symbolic input

Qc = [B_sym A*B_sym (A^2)*B_sym (A^3)*B_sym];
Rank_QC = rank(Qc); % =4 thus, states are controllable
n = size(A,1);
if double(Rank_QC) == n
    fprintf('Controllability: rank(Qc) = %d = n  -> controllable.\n', double(Rank_QC));
else
    fprintf('Controllability: rank(Qc) = %d < %d -> NOT controllable.\n', double(Rank_QC), n);
end

% Observability = ability to draw conclusions about system states from
% output. Rank of Qo matrix = n = 4 for observability.
C_obs = C_full;             % full sensor set: (load position + crane velocity)
Qo = [C_obs; C_obs*A; C_obs*(A^2); C_obs*(A^3)];
Rank_Qo = rank(Qo); % =4 thus, observable.

if double(Rank_Qo) == n
    fprintf('Observability:   rank(Qo) = %d = n  -> observable.\n', double(Rank_Qo));
else
    fprintf('Observability:   rank(Qo) = %d < %d -> NOT observable.\n', double(Rank_Qo), n);
end

% Stability
% At equilibrium point, f = 0, x_dot = 0 and x_c = x_l = const. = c
% u_eq = 0 -> g(u_eq) = 0 -> B = 0 -> f(x_eq, u_eq) = 0
% B is not dependent on x, therefore jacobian of system states = A
% (J_x = df/dx = A)
% Therefore stability can be checked by eig(A). 
% Check if all eigenvalues have negative real parts
Eigs = eig(A);

if all(real(Eigs) < -1e-9)
    fprintf('Stability:       all Re(eig) < 0  -> asymptotically stable.\n');
elseif any(real(Eigs) > 1e-9)
    fprintf('Stability:       max Re(eig) = %.2g > 0 -> unstable.\n', max(real(Eigs)));
else
    fprintf('Stability:       max Re(eig) = %.2g -> marginally stable.\n', max(real(Eigs)));
end
% One eig has Re=0 -> marginally stable.
% Explained by the line of equilibria

%% b) Non-linear model, measurement and Jacobian
% Defined as functions in the functions/ folder:
%   state_definition.m  -> x_dot = f(x,u)
%   mes_definition.m    -> y     = h(x,u)
%   jacobianSys.m       -> [A, B] = d f / d x , d f / d u
% strct is used as shared memory for variables, e.g.:
strct.T_s        = T_s;
strct.Hsim       = Hsim;
strct.T_max      = T_max;

if RBF_MOD && exist('RBF','var'), strct.RBF = RBF; end

sys.f = @(x,u)(state_definition(x,u, strct));
sys.h = @(x,u)(mes_definition(x,u, strct));
strct.sys = sys;

if isfield(strct,'RBF'), fprintf('Slip model: identified RBF.\n'); else, fprintf('Slip model: atan fallback.\n'); end


%% c) Initialize the NMPC
% Set up nlmpc(), choose horizons and weighting matrices, validate with
% validateFcns(). Constraints:
%        min   max
%   u    -5     5
%   du   -6     6
%   x1  -50    50

% Hp, Hc, Q, R -> params.m

nlmpcobj = nlmpc(4,1,1);
nlmpcobj.Ts = T_s;
nlmpcobj.PredictionHorizon = Hp;
nlmpcobj.ControlHorizon = Hc;
nlmpcobj.Weights.ManipulatedVariables = R;
nlmpcobj.Weights.OutputVariables = Q;
nlmpcobj.Model.StateFcn =@(x, u) state_definition(x, u, strct);
nlmpcobj.Model.OutputFcn =@(x, u) mes_definition(x, u, strct);
nlmpcobj.Model.IsContinuousTime= true;
nlmpcobj.Jacobian.StateFcn =@(x, u) jacobianSys(x, u, strct);

% Constraints
nlmpcobj.ManipulatedVariables.Max = u_max;
nlmpcobj.ManipulatedVariables.Min = u_min;
nlmpcobj.ManipulatedVariables.RateMax = du_max*T_s;
nlmpcobj.ManipulatedVariables.RateMin = du_min*T_s;
nlmpcobj.OutputVariables(1).Max = x1_max;
nlmpcobj.OutputVariables(1).Min = x1_min;

% Validate fns
% Check at an equilibrium point.
x0 = [0; 1; 1; 1];
u0 = 0;

nlmpcobj.validateFcns(x0,u0) 

%% d) Simulate a setpoint change and check real-time capability
% Scenario: lift load to x = 0 (hold briefly), move to x = 5, return to
% x = 0 after 15 s. Use tic ... toc to time the control computation.

% Simulation params
t_end = sim_t_end;
t_lin = 0:T_s:t_end;

y_ref = [0*(0:T_s:sim_hold0-T_s), ...
         sim_move*ones([1, length(sim_hold0:T_s:sim_back-T_s)]), ...
         0*ones([1, length(sim_back:T_s:t_end+Hp)])];

% y_ref = zeros(1,267);

% Initial conditions
x = [0; 1; 1; 1];
u = u0;

% Storage
X_stor = zeros(4, length(t_lin));
U_stor = zeros(1, length(t_lin)); 
yRef_stor = zeros(length(t_lin));
Xcon_stor = [];
tcon_stor = [];

tic
for k = 1:length(t_lin)

    % MPC-Control
    u = nlmpcmove(nlmpcobj,x,u,y_ref(k:k+Hp)');
    
    % Storage
    U_stor(:,k) = u;
    X_stor(:,k) = x;
    yRef_stor(k) = y_ref(k);

    % System update
    [x, t_nl, x_nl] = discreteF(x,u,strct);
    y = sys.h(x,u);

    Xcon_stor = [Xcon_stor x_nl'];
    tcon_stor = [tcon_stor, (k-1)*T_s+t_nl'];

end
elapsed = toc;
avg_ms  = 1e3*elapsed/numel(t_lin);
if avg_ms < 1e3*T_s, rt = 'real-time capable'; else, rt = 'NOT real-time'; end
fprintf('NMPC: %d steps, %.1f ms/step (T_s = %.0f ms) -> %s.\n', ...
        numel(t_lin), avg_ms, 1e3*T_s, rt);

% Plot
figure;
subplot(5,1,1);
stairs(t_lin, X_stor(1,:)); hold on;
plot(tcon_stor, Xcon_stor(1,:))
plot(t_lin, yRef_stor, '--')
legend('System (discrete)', 'System (cont.)','Reference', 'Location', 'northeast')
ylabel('x load (x_1)')

subplot(5,1,2);
stairs(t_lin, X_stor(2,:)); hold on;
plot(tcon_stor, Xcon_stor(2,:))
ylabel('v load (x_2)')

subplot(5,1,3);
stairs(t_lin, X_stor(3,:)); hold on;
plot(tcon_stor, Xcon_stor(3,:))
ylabel('x crane (x_3)')

subplot(5,1,4);
stairs(t_lin, X_stor(4,:)); hold on;
plot(tcon_stor, Xcon_stor(4,:))
ylabel('v crane (x_4)')

subplot(5,1,5);
stairs(t_lin, U_stor , '--');
ylabel('control input [T]');
xlabel('Time (h)');

%% Plotting and Animation
 %res.t   = t_lin;
 %res.X   = X_stor;                    % 4 x N states
 %res.u   = U_stor;                    % 1 x N input
 %res.ref = y_ref(1:numel(t_lin));     % load-position reference
 %plotCraneResults(res, 'Title', 'NMPC', 'Animate', true);