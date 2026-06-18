%% Task 1 - Approximate the non-linearity
% Identify the input-channel non-linearity (slip) of the crane from
% Patrick's impulse-response measurements and approximate it with an
% RBF network.

%% a) Average the repeated measurements and inspect the data
% Patrick repeated each test several times so the measurement noise can be
% averaged out. Average and check the data.
% ... your code ...

%% b) Compute crane accelerations from velocities
% The RBF network needs the pure crane accelerations driven by input u, but
% only velocities are measured. Use difference quotients for the derivative
% and add the velocity loss (negative acceleration) due to friction.
% ... your code ...

%% c) Determine the RBF network weights
% Fit a Gaussian-basis RBF network to the accelerations and compute the
% weights.
% ... your code ...

%% d) Build and validate the slip function
% Use predictRBF_craneTime(u, RBF) to map an input u to the effective
% acceleration with slip. Plot training data vs. the approximation.
% RBF.centers = centers;
% RBF.sigma   = sigma_rbf;
% RBF.weights = w;
% RBF.t_lin   = t_lin;
% ... your code ...

%% e) Draw the angle bisector (x = y) and interpret
% Add the line x = y to the plot and interpret what it reveals about slip.
% ... your code ...
