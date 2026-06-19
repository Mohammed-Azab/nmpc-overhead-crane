function x = discreteF(x, u, strct)
% DISCRETEF  One-step discrete propagation of the non-linear system.
%   x = discreteF(x, u, strct) integrates x_dot = f(x,u) over one sample T_s.
%
%   [~, x_vec] = ode45(@(t,x)(strct.sys.f(x,u)), [0 strct.T_s], x);
%   x = x_vec(end,:)';

    % ... your code ...
end
