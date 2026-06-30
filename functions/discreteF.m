function [x, t_nl, x_nl] = discreteF(x, u, strct)
% DISCRETEF  One-step discrete propagation of the non-linear system.
%   x = discreteF(x, u, strct) integrates x_dot = f(x,u) over one sample T_s.
%
  [t_nl, x_nl] = ode45(@(t,x)(strct.sys.f(x,u)), [0 strct.T_s], x);
  x = x_nl(end,:)';

end
