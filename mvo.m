function [x_short, R_short, std_devi_short, x_noshort, R_noshort, std_devi_noshort] = forfun()

% --- 1. Data Loading (Assuming files are correct) ---
stats = readtable('forfun_monthly_stats.csv', 'ReadRowNames', true);
covtab = readtable('forfun_population_explicit.csv', 'ReadRowNames', true);

% Assigning variables from CSVs
mu = stats.mean_monthly_geo;
tickers = covtab.Properties.RowNames;
Q = table2array(covtab);

% Final Data Preparation
mu = mu(:);
n = numel(mu);
num_points = 20;

R_min = min(mu);
R_max = max(mu);
goal_R = linspace(R_min, R_max, num_points)';

c = zeros(n, 1);
Aeq = ones(1, n);
beq = [1];

% Shorting Allowed
x_short = zeros(num_points, n);
fval_short = zeros(num_points, 1);
std_devi_short = zeros(num_points, 1);

for a = 1:length(goal_R)
    A = -mu';
    b = -goal_R(a);

    % Solve
    [x_short(a,:), fval_short(a,1)] = quadprog(Q, c, A, b, Aeq, beq, [], []);
    std_devi_short(a,1) = (x_short(a,:)*Q*x_short(a,:)')^.5; % standard deviation = (x'*Q*x)^.5
end
R_short = goal_R;

% No Shorting
lb_noshort = zeros(n, 1); 
x_noshort = zeros(num_points, n);
fval_noshort = zeros(num_points, 1);
std_devi_noshort = zeros(num_points, 1);

for a = 1:length(goal_R)
    A = -mu';
    b = -goal_R(a);
    % Solve
    [x_noshort(a,:), fval_noshort(a,1)] = quadprog(Q, c, A, b, Aeq, beq, lb_noshort, []);
    std_devi_noshort(a,1) = (x_noshort(a,:)*Q*x_noshort(a,:)')^.5; % standard deviation = (x'*Q*x)^.5
end

R_noshort = goal_R;


% Plotting and Table Generation
figure;
hold on;
plot(std_devi_short, R_short, '-r*', 'LineWidth', 1.5, 'DisplayName', 'Shorting Allowed');
plot(std_devi_noshort, R_noshort, '-bo', 'LineWidth', 1.5, 'DisplayName', 'No Shorting');
xlabel('Portfolio Volatility (\sigma)');
ylabel('Expected Return Goal (R)');
title('Mean-Variance Efficient Frontier (8 Assets)');
legend('show', 'Location', 'NorthWest');
grid on;
hold off;

% Dynamic table header generation
header_str = 'R Target (%%) | Std Dev (%%)';
for i = 1:n
    header_str = [header_str, ' | Weight ', tickers{i}];
end
separator = repmat('-', 1, length(header_str) + (n*3)); 

% Print table data for the report (Shorting Allowed)
fprintf('\n%s\n', separator);
fprintf('TABLE DATA: Shorting Allowed\n');
fprintf('%s\n', header_str);
fprintf('%s\n', separator);
for a = 1:num_points
    fprintf('%10.4f | %11.4f | ', R_short(a)*100, std_devi_short(a)*100);
    fprintf(repmat('%10.4f', 1, n), x_short(a,:));
    fprintf('\n');
end

% Print table data for the report (No Shorting)
fprintf('\n%s\n', separator);
fprintf('TABLE DATA: No Shorting\n');
fprintf('%s\n', header_str);
fprintf('%s\n', separator);
for a = 1:num_points
    fprintf('%10.4f | %11.4f | ', R_noshort(a)*100, std_devi_noshort(a)*100);
    fprintf(repmat('%10.4f', 1, n), x_noshort(a,:));
    fprintf('\n');
end
end