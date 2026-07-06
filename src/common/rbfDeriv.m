function d = rbfDeriv(u, RBF)
% rbfDeriv  Derivative dg/du of the Gaussian RBF network.

%   d/du sum_i w_i exp(-(u-c_i)^2/(2 s^2))
%     = sum_i w_i (-(u-c_i)/s^2) exp(-(u-c_i)^2/(2 s^2))

    c = RBF.centers(:)';  w = RBF.weights(:);  s = RBF.sigma;
    uc  = u(:);
    Phi = exp(-(uc - c).^2 / (2*s^2));
    d   = reshape((Phi .* (-(uc - c)/s^2)) * w, size(u));
end
