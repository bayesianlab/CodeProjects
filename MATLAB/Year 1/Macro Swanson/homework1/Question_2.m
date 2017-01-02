%% Question 2
clear 
clc

[t, cpi] = import_fred_data('cpi.csv', 2, 711);
[t, t_bonds] = import_fred_data('t_bonds.csv', 2, 756);
[time, output] = import_fred_data('INDPRO.csv', 2, 1167);
february1958 = 470;
start_sample = february1958-12;


output_log_diff = vertcat(0, diff(log(output)));

cpi = vertcat(zeros(456,1), cpi);
cpi_log_diff = vertcat(0, diff(log(cpi)));
t_bonds = vertcat(zeros(411,1), t_bonds);
output_t = output(february1958-12:length(output));
log_output_t = log(output_t);

D = [ output cpi_log_diff t_bonds];
[end_sample, num_vars] = size(D);
D= horzcat(time, num2cell(D));

% Samples

output_log_diff_t = output_log_diff(start_sample:end_sample,1);
cpi_log_diff_t = cpi_log_diff(start_sample:end_sample,1);
t_bonds_t = t_bonds(start_sample:end_sample,1);
Data = [output_log_diff_t, cpi_log_diff_t, t_bonds_t];
[row, col] = size(Data)

% Estimate VAR
[ coef, resids ] = var(Data, 12);
cov(resids)
coef
X_t = vectorized_lags(Data, 12);
[n, c] = size(X_t);
time_t = [ 1 output_log_diff_t(row), X_t(n, 2:12), cpi_log_diff_t(row),...
    X_t(n, 14:24), t_bonds_t(row), X_t(n, 26:36)];
[cur, fore] = var_forecast(time_t, coef, 10);
fore

for i = 1:10
    if i == 1
        level_fores(i,1) = fore(i,1) + log(output(end_sample));
    else
        
        level_fores(i,1) = (fore(i,1) + (level_fores(i-1,1)));
    end
 end
level_fores

