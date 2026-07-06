%% loadSystem  
%   Build the crane system.
%   Running this script defines the model variables used by every task:
%     Hsim              number of simulation steps
%     g, dgdu           slip non-linearity and its derivative
%     f, h              continuous dynamics x_dot = f(x,u), output y = h(x,u)
%     jacA, jacB        Jacobians  df/dx (constant A) and df/du (function of u)
%     stepF             one-step propagation over T_s


% make sure the parameters are loaded
if ~exist('A', 'var') || ~exist('T_s', 'var')
    params;
end

Hsim = ceil(T_max / T_s);

% slip non-linearity
if exist('RBF', 'var') && ~isempty(RBF)
    g    = @(u) predictRBF_craneTime(u, RBF);
    dgdu = @(u) rbfDeriv(u, RBF);
else
    g    = g_fallback;
    dgdu = dgdu_fallback;
end

% model equations
f    = @(x,u) A*x + [0; 0; 0; g(u)];
h    = @(x,u) C*x;
jacA = A;                              % df/dx (independent of x and u)
jacB = @(u) [0; 0; 0; dgdu(u)];        % df/du
stepF = @(x,u) stepODE(f, x, u, T_s);  % one-step integration over T_s
