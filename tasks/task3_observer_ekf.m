%% Task 3 - Implement an observer
% Add a continuous-discrete Extended Kalman Filter (EKF): between two
% measurements solve the system numerically to obtain the next state
% estimate.

%% a) NMPC without observer vs. the "real" crane
% Simulate the NMPC without an observer and compare against the crane's
% "real" system. What stands out?
%
% Provided helper commands:
%   initializeCran;  response_real = 0;            % setup crane
%   [response_real, crane] = responseCran(u, crane); % real (noisy) measurement
% ... your code ...

%% b) Implement the Kalman Filter
% Implement the EKF and check the NMPC against the real system using
% responseCran for the "real" measurement. Choose the covariance matrices
% appropriately.
% ... your code ...

%% Real-time check
% Measure the computation time of the manipulated variable over all
% iterations and plot the results. Is the system still real-time capable,
% and what can be done to guarantee it?
% ... your code ...
