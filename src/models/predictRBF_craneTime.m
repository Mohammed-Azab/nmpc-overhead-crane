function y = predictRBF_craneTime(u, RBF)
% g(u) from the trained RBF network.
    y = reshape(exp(-(u(:) - RBF.centers(:).').^2 / (2*RBF.sigma^2)) * RBF.weights(:), size(u));
end