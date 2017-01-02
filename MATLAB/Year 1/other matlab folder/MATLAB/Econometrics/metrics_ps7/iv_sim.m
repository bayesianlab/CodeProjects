function [ IV_estimates, residuals, ols_est, CI ] = iv_sim( mu,sigma,...
    rows, columns, betaTrue, weakness )


weak_instrument = normrnd(mu,sigma,rows,columns);
errorTerm = normrnd(mu,sigma, rows, columns);
endogenous_error = errorTerm + normrnd(mu,sigma,rows,columns);
X_Endogeneous =  weakness*weak_instrument + 0*normrnd(mu,sigma, rows, columns)...
    + endogenous_error;
projection = weak_instrument * inv( weak_instrument' * weak_instrument)*...
    weak_instrument';
X_Exogeneous = normrnd(mu,sigma,rows,columns);
X_Mat =[X_Endogeneous X_Exogeneous];
y_experiment =  X_Mat*betaTrue + errorTerm;
IV_estimates = twoSLS(X_Endogeneous, weak_instrument,...
    y_experiment);
beta_ols = betaOLS(X_Exogeneous, y_experiment);
coeffs = [IV_estimates; beta_ols];
yHat = X_Mat * coeffs;
residuals = y_experiment - yHat;
ols_est = betaOLS(X_Endogeneous, y_experiment);

% Confidence Inverval
z_stat = 1.96;
sigma_sqd = residuals'*residuals/rows;
se_iv = sqrt(sigma_sqd * inv(X_Endogeneous' * projection * X_Endogeneous));
ci_95th_up = IV_estimates + se_iv*z_stat;
ci_95th_low = IV_estimates - se_iv*z_stat;
CI = [ci_95th_low, ci_95th_up];


end

