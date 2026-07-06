%% Task 1
loadSystem;
fprintf('Loaded %d experiments, %d reps each.\n', ...
        numel(steps_size)/repeat, repeat);

%% a) Average the repeated measurements
figure; set(gcf,'Color','w'); try, theme(gcf,'light'); catch, end
colors = parula(length(steps_size));
i = 1;
while i <= length(steps_size) - repeat + 1
    Avg_data  = mean(positionLoad(i:i+repeat-1, :));
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
title(sprintf('%d reps', repeat))
grid on
colorbar
colormap(parula)
set(gca,'Color','w','XColor',[0.15 0.15 0.15],'YColor',[0.15 0.15 0.15])

%% b) Crane acceleration from velocity:
% From row 4 of the model:  v_crane_dot = -0.2*v_crane + g(u)
%   =>   g(u) = dv/dt + 0.2*v
d      = friction;
nExp   = length(steps_size) / repeat;
u_train = zeros(nExp, 1);
g_train = zeros(nExp, 1);

idx = 1;
for e = 1:nExp
    v_avg = mean(speedCrane(idx:idx+repeat-1, :), 1);

    % g(u) = dv/dt + 0.2*v
    a_rec = diff(v_avg) / T_s + d * v_avg(1:end-1);

    [~, kPeak] = max(abs(a_rec));

    u_train(e) = steps_size(idx);
    g_train(e) = a_rec(kPeak);

    idx = idx + repeat;
end

% sorting the data to be monotone in 'u'
[u_train, order] = sort(u_train);
g_train = g_train(order);

fprintf('\nReconstructed %d (u, g) pairs, u in [%.2f, %.2f].\n', ...
        nExp, min(u_train), max(u_train));

%% c) RBF weights by least squares
N         = rbf_N;
centers   = linspace(min(u_train), max(u_train), N);
sigma_rbf = rbf_sigma_factor * mean(diff(centers));

Phi = zeros(numel(u_train), N);
for i = 1:N
    Phi(:, i) = exp(-(u_train - centers(i)).^2 / (2 * sigma_rbf^2));
end
w = Phi \ g_train;

rmse = sqrt(mean((Phi*w - g_train).^2));
fprintf('\nRBF fit: N = %d centers, sigma = %.3f, RMSE = %.4f.\n', N, sigma_rbf, rmse);


%% d) Slip function and validation
RBF.centers = centers;
RBF.sigma   = sigma_rbf;
RBF.weights = w;
RBF.t_lin   = t_lin;

u_query = linspace(min(u_train), max(u_train), 400)';
g_query = predictRBF_craneTime(u_query, RBF);

fprintf('\nSlip at u = %.1f: g = %.2f (%.0f%% delivered).\n', ...
        u_query(end), g_query(end), 100*g_query(end)/u_query(end));

figure; set(gcf,'Color','w'); try, theme(gcf,'light'); catch, end
plot(u_train, g_train, 'kx', 'MarkerSize', 9, 'LineWidth', 1.5, ...
     'DisplayName', 'training data')
hold on
plot(u_query, g_query, 'r-', 'LineWidth', 2, 'DisplayName', 'RBF approximation')

%% e) Bisector g(u) = u
plot(u_query, u_query, 'b--', 'LineWidth', 1.2, 'DisplayName', 'g(u) = u')

xlabel('commanded input acceleration  u')
ylabel('effective crane acceleration  g(u)')
title('Task 1: input non-linearity (slip) via RBF network')
legend('show', 'Location', 'northwest')
grid on
axis equal
set(gca,'Color','w','XColor',[0.15 0.15 0.15],'YColor',[0.15 0.15 0.15])

