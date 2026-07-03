function x_dot = state_definition(x, u, strct)
% STATE_DEFINITION  Non-linear state derivative x_dot = f(x,u).
%   x_ = state_definition(x, u, strct) returns the continuous-time
%   derivative of the crane state vector x = [x_load; v_load; x_crane; v_crane].
%   strct carries shared parameters (T_s, RBF, predictRBF, ...).
    A = [0 1 0 0; -3 -0.1 3 0.1; 0 0 0 1; 0 0 0 -2];

    g = @(u) (20/pi())*atan((pi()/20)*u);
    B = [0; 0; 0; g(u)];

    x_dot = A*x + B;
end
