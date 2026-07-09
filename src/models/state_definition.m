function x_dot = state_definition(x, u, strct)
% STATE_DEFINITION  Non-linear state derivative x_dot = f(x,u).

    A = strct.A;
    B = strct.B;

    if isfield(strct, 'RBF') && ~isempty(strct.RBF)
        R = strct.RBF;  c = R.centers(:).';  w = R.weights(:);  s = R.sigma;
        g = @(u) exp(-(u - c).^2 / (2*s^2)) * w;
    else
        g = @(u) (20/pi())*atan((pi()/20)*u);
    end

    x_dot = A*x + B*g(u);
end
