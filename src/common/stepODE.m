function x_next = stepODE(f, x, u, T_s)
% stepODE  One-step propagation of x_dot = f(x,u) over a sample T_s.
    [~, xv] = ode45(@(t,z) f(z, u), [0 T_s], x);
    x_next  = xv(end, :)';
end
