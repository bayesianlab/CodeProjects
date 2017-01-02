%% Part a
clear
clc

[t, cpi] = import_fred_data('cpi.csv', 2,831);
[t, t_bonds] = import_fred_data('t_bonds.csv', 2, 756);
[time, output] = import_fred_data('INDPRO.csv', 2, 1167);
febuary1958 = 470;
end_date = length(output);
forecast_visual = 600;

cpi = vertcat(zeros(456,1), cpi);
t_bonds = vertcat(zeros(411,1), t_bonds);
log_diff_cpi = vertcat(0, diff(log(cpi)));


cpi_t = cpi(febuary1958 -2:length(cpi));
output_t = output(febuary1958-2:length(output));
log_output_t = log(output_t);
log_diff_cpi_t = log_diff_cpi(febuary1958-2:length(log_diff_cpi),1);
t_bonds_t = t_bonds(febuary1958-2:length(cpi));


data = [log_output_t log_diff_cpi_t t_bonds_t];
X_t = vectorized_lags(data,2);
[n, c] = size(X_t);
output_lag1 = X_t(:,3);
ldcpi_lag1 = X_t(:,5);
t_bonds_lag1 = lag_variable(t_bonds_t,1);
log_cpi_lag1 = log(lag_variable(cpi_t, 1));
log_cpi_lag1= log_cpi_lag1(2:length(log_cpi_lag1));

%% VAR Estimates 
[var_estimates, residuals] = vreg(data, 2);
betas = var_estimates(:,1);
gammas = var_estimates(:,2);
deltas = var_estimates(:,3);
var_estimates

%% Resdiual Covariances
covar_resids = cov(residuals)
u_y = residuals(:,1);
u_pi = residuals(:,2);
u_i = residuals(:,3);

forecast_output = (X_t(n,:)*var_estimates(:,1));
% forecast_inflation = exp(X_t(n,:)*var_estimates(:,2) +...
%     log(cpi(end_date,1)));

forecast_t_bonds = X_t(n,:)*var_estimates(:,3);

time_t =[ 1, log_output_t(n+2), X_t(n,2), log_diff_cpi_t(n+2),...
    X_t(n,4) t_bonds_t(n+2), X_t(n,6)];
[forecast_results, fore] = forecast(time_t, var_estimates, 10);
output_lr_forecast = (fore(:,1));
inflation_lr_forecast = fore(:,2);
t_bonds_lr_forecast = fore(:,3);
FOREs = [output_lr_forecast, inflation_lr_forecast, t_bonds_lr_forecast];


% [a,b,c,d,e,f] = VAR_Swan(data, 2);
% cov(residuals)

in_sample_ouput = (X_t*betas);
% in_sample_inflation = exp(X_t*gammas + log_cpi_lag1);
in_sample_inflation = X_t*gammas ;
in_sample_t_bonds = X_t*deltas;

forecast_output_series = vertcat(in_sample_ouput, forecast_output);
forecast_inflation_series = vertcat(in_sample_inflation,...
    inflation_lr_forecast);
forecast_t_bonds_series = vertcat(in_sample_t_bonds, forecast_t_bonds);

x_axe = 1:n;
output_t = output_t(3:length(output_t));
cpi_t = cpi_t(3:length(cpi_t));
t_bonds_t = t_bonds_t(3:length(t_bonds_t));

% figure
% plot(x_axe, in_sample_ouput, x_axe, log_output_t(3:length(log_output_t)))
% legend('In Sample Forecast Output', 'Output','Location', 'northwest')
% 
% x_axe = 500:n;
% figure
% p = log_diff_cpi_t(3:length(log_diff_cpi_t));
% plot(x_axe, in_sample_inflation(x_axe), x_axe, p(x_axe))
% legend('In Sample Forecast Inflation', 'Inflation','Location', 'northwest')
% x_axe = 1:n;
% figure
% plot(x_axe, in_sample_t_bonds, x_axe, t_bonds_t)
% legend('In Sample Forecast T-Bills', 'T-Bills','Location','northwest')
% 
% figure
% plot(forecast_output_series(forecast_visual:length(forecast_output_series), 1))
% hold on 
% plot(output_t(forecast_visual:length(output_t), 1))
% legend('Forecast', 'Output','Location','northwest')

% figure 
% plot(forecast_inflation_series(forecast_visual:...
%     length(forecast_inflation_series)))
% hold on
% plot(log_diff_cpi_t(forecast_visual:length(log_diff_cpi_t)));
% legend('Forecast', 'Inflation','Location','northwest')

% figure
% plot(forecast_t_bonds_series(forecast_visual:...
%     length(forecast_t_bonds_series)))
% hold on
% plot(t_bonds_t(forecast_visual:length(t_bonds_t)))
% legend('Forecast', 'T-Bill Maturity Yield','Location','northwest')
% 
% 
% 


