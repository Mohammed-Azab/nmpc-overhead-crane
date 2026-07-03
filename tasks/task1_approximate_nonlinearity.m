%% Task 1 - Approximate the non-linearity
% Identify the input-channel non-linearity (slip) of the crane from
% Patrick's impulse-response measurements and approximate it with an
% RBF network.

% Add project folders to the path
addpath('tasks');
addpath('functions');
addpath('provided');
addpath('templete');

T_max = 100; % stop time for patricks experiment
T_s = 0.15; %sample time for patricks experiment (can be changed)

Hsim = ceil(T_max/T_s);

repeat = 100;
t_lin = linspace(0, T_s*(Hsim-1), Hsim);
[positionLoad, steps_size, speedCrane] = simulateCran_multi(T_s, Hsim, repeat);     % load System

%% a) Average the repeated measurements and inspect the data
% Patrick repeated each test several times so the measurement noise can be
% averaged out. Average and check the data.

figure
colors = parula(length(steps_size));
i = 1;
while i <= length(steps_size) - repeat + 1
    Avg_data = mean(positionLoad(i:i+repeat-1, :));
    Norm_data = Avg_data / steps_size(i);
    plot(t_lin, Norm_data, ...
        'Color', colors(i,:), ...
        'LineWidth', 1.5, ...
        'DisplayName', sprintf('acceleration = %.2f', steps_size(i)));
    hold on
    i = i + repeat;
end
xlabel('Time (s)')
ylabel('Normalised Position')
legend('show', 'Location', 'bestoutside')
title('100 reps')
grid on
colorbar
colormap(parula)



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
