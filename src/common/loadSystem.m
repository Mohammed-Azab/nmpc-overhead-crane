%% loadSystem
%   Build the crane system.

% make sure the parameters are loaded
if ~exist('A', 'var') || ~exist('T_s', 'var')
    params;
end

Hsim   = ceil(T_max / T_s);
repeat = rbf_repeat;
t_lin  = linspace(0, T_s*(Hsim-1), Hsim);
[positionLoad, steps_size, speedCrane] = simulateCran_multi(T_s, Hsim, repeat);

% slip non-linearity
if exist('RBF', 'var') && ~isempty(RBF)
    g = @(u) reshape(exp(-(u(:) - RBF.centers(:).').^2 / (2*RBF.sigma^2)) * RBF.weights(:), size(u));
else
    g = g_fallback;
end

% model equations
f     = @(x,u) A*x + [0; 0; 0; g(u)];
stepF = @(x,u) stepODE(f, x, u, T_s);   % one-step integration over T_s
