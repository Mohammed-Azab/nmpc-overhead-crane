function [A, B] = jacobianSys(x, u, strct)
% JACOBIANSYS  Jacobians of the non-linear system.
%   [A, B] = jacobianSys(x, u, strct) returns A = df/dx and B = df/du.

    A     = strct.A;
    Bmask = strct.B;

    if isfield(strct, 'RBF') && ~isempty(strct.RBF)
        R = strct.RBF;  c = R.centers(:).';  w = R.weights(:);  s = R.sigma;
        dgdu = @(u) (exp(-(u - c).^2 / (2*s^2)) .* (-(u - c)/s^2)) * w;
    else
        dgdu = @(u) 1 ./ ((pi^2 .* u.^2)/400 + 1);
    end
    B = Bmask * dgdu(u);
end
