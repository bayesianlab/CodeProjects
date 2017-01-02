%% Part e
clear
clc
format 

[t, cpi] = import_fred_data('cpi.csv', 2, 711);
[t, t_bonds] = import_fred_data('t_bonds.csv', 2, 756);
[time, output] = import_fred_data('INDPRO.csv', 2, 1167);
february1958 = 470;
end_date = length(output);


cpi = vertcat(zeros(456,1), cpi);
log_diff_cpi = vertcat(0, diff(log(cpi)));
t_bonds = vertcat(zeros(411,1), t_bonds);


D = [ output log_diff_cpi t_bonds];
D= horzcat(time, num2cell(D));
cpi_t = cpi(february1958-12:length(cpi));
log_cpi = log(cpi_t);
log_cpi_lag1 = lag_variable(log_cpi,1);
log_cpi_lag1 = log_cpi_lag1(12:length(log_cpi_lag1));
output_t = output(february1958-12:length(output));
log_output_t = log(output_t);
log_diff_cpi_t = log_diff_cpi(february1958-12:length(log_diff_cpi),1);
t_bonds_t = t_bonds(february1958-12:length(cpi));

data = [log_output_t, log_diff_cpi_t, t_bonds_t];
[row col] =size(data)

%% Estimate VAR(12)
[var_coeffs resids] = var(data, 12);
var_coeffs
results = var_coeffs;
sz_coef = size(var_coeffs);
results;
resid_cov = cov(resids)
% a = VAR_Swan(data, 12);

X_t = vectorized_lags(data, 12);
[n,c] = size(X_t);

insample_stuff = X_t * var_coeffs;
output_insample = exp(insample_stuff(:,1));
inf_insample = exp(insample_stuff(:,2) + log_cpi_lag1);
int_insample = insample_stuff(:,3);
size(output_insample)
time_t = [ 1 log_output_t(row), X_t(n, 2:12), log_diff_cpi_t(row),...
    X_t(n, 14:24), t_bonds_t(row), X_t(n, 26:36)]

[ curr, nxt ] =  var_forecast(time_t, var_coeffs, 10);
nxt
fcastvar(10, data, 12)
y_fore = (nxt(:,1));
inflation = nxt(:,2);
pi_fore = transform_inflation( nxt(:,2), log(cpi_t(length(cpi_t),1)));
i_fore = nxt(:,3);
FOREs = [y_fore, inflation, i_fore]

output_t_for_plot = output_t(13:length(output_t));
cpi_t_for_plot = cpi_t(13:length(cpi_t));
int_for_plot = t_bonds_t(13:length(t_bonds_t));
out =  vertcat(output_insample, y_fore);
inf = vertcat(inf_insample, pi_fore);
int = vertcat(int_insample, i_fore);

% visual_begin = 600;
% figure
% x_ax = visual_begin:length(output_t_for_plot);
% plot(x_ax,output_t_for_plot(x_ax))
% hold on
% ax2 = visual_begin:length(out);
% plot(ax2, out(ax2))
% legend('Output', 'Output Forecast', 'Location', 'northwest')
% 
% visual_begin = 680;
% figure
% x_ax = visual_begin:length(cpi_t_for_plot);
% plot(x_ax,cpi_t_for_plot(x_ax))
% hold on
% ax2 = visual_begin:length(inf);
% plot(ax2, inf(ax2))
% legend('Forecast', 'Inflation','Location','northwest')
% 
% visual_begin = 650;
% figure
% x_ax = visual_begin:length(int_for_plot);
% r = length(int_for_plot);
% plot(x_ax, int_for_plot(x_ax))
% hold on
% ax2 = visual_begin:length(int);
% plot(ax2, int(ax2))
% legend('Forecast', 'T-Bill Maturity Yield','Location','northwest')
% 
% 
% 




