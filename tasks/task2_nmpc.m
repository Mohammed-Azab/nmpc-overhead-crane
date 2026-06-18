%% Task 2 - Crane with NMPC
% In day-to-day operation only the load position is measured, so y = x_load.
%
% Remark: If no function was found in Task 1, use
%   g(u)      = (20/pi) * atan((pi/20)*u)
%   dg(u)/du  = ( (pi^2 * u^2)/400 + 1 )^(-1)
% otherwise use the RBF function.

%% a) System analysis
% Examine controllability, observability and stability of the system.
% ... your code ...

%% b) Non-linear model, measurement and Jacobian
% Defined as functions in the functions/ folder:
%   state_definition.m  -> x_dot = f(x,u)
%   mes_definition.m    -> y     = h(x,u)
%   jacobianSys.m       -> [A, B] = d f / d x , d f / d u
% strct is used as shared memory for variables, e.g.:
% strct.T_s        = T_s;
% strct.Hsim       = Hsim;
% strct.T_max      = T_max;
% strct.predictRBF = predictRBF;
% strct.RBF        = RBF;
% sys.f = @(x,u)(state_definition(x,u, strct));
% sys.h = @(x,u)(mes_definition(x,u, strct));
% strct.sys = sys;

%% c) Initialize the NMPC
% Set up nlmpc(), choose horizons and weighting matrices, validate with
% validateFcns(). Constraints:
%        min   max
%   u    -5     5
%   du   -6     6
%   x1  -50    50
% Useful commands: nlmpc()
% ... your code ...

%% d) Simulate a setpoint change and check real-time capability
% Scenario: lift load to x = 0 (hold briefly), move to x = 5, return to
% x = 0 after 15 s. Use tic ... toc to time the control computation.
% ... your code ...
