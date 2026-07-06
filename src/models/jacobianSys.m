function [A, B] = jacobianSys(x, u, strct)
% JACOBIANSYS  Jacobians of the non-linear system.
%   [A, B] = jacobianSys(x, u, strct) returns
%     A = d f / d x
%     B = d f / d u
%   The RBF derivative can be written as
%     d/dx sum_i theta_i exp(-(x-mu_i)^2/(2 sigma^2))
%       = sum_i -theta_i (x-mu_i)/sigma^2 exp(-(x-mu_i)^2/(2 sigma^2)).
    
    A = [0 1 0 0; -3 -0.1 3 0.1; 0 0 0 1; 0 0 0 -0.2]; % B not dependent on x

    % df/du: only through g(u) in the bottom row
    dgdu = @(u) 1 ./ ((pi^2 .* u.^2)/400 + 1);   % derivative of atan slip fallback
    B = [0; 0; 0; dgdu(u)];
end
