function [A, B] = jacobianSys(x, u, strct)
% JACOBIANSYS  Jacobians of the non-linear system.
%   [A, B] = jacobianSys(x, u, strct) returns
%     A = d f / d x
%     B = d f / d u
%   The RBF derivative can be written as
%     d/dx sum_i theta_i exp(-(x-mu_i)^2/(2 sigma^2))
%       = sum_i -theta_i (x-mu_i)/sigma^2 exp(-(x-mu_i)^2/(2 sigma^2)).

    % ... your code ...
    A = [];
    B = [];
end
