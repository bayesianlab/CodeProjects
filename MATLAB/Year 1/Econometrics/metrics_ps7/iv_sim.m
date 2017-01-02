function [ IV_estimates, residuals, OLS_estimates, CI ] =...
    iv_sim( mu,sigma,rows, columns, betaTrue, weakness )

weak_instrument = normrnd(mu,sigma,rows,columns);
errorTerm = normrnd(mu,sigma, rows, columns);
X_Endogeneous =  weakness*weak_instrument + normrnd(mu,sigma, rows, columns)...
    + 3*errorTerm;
X_Exogeneous = normrnd(mu,sigma,rows,columns);
X_Mat =[X_Endogeneous X_Exogeneous];
Z_Mat = [weak_instrument, X_Exogeneous];
y_experiment =  X_Mat*betaTrue + errorTerm;
IV_estimates = twoSLS(X_Mat,Z_Mat, y_experiment);

OLS_estimates = betaOLS(X_Mat, y_experiment);

% Confidence Inverval
projection = weak_instrument * inv( weak_instrument' * weak_instrument)*...
    weak_instrument';
z_stat = 1.96;
yHat = X_Mat*IV_estimates;
residuals = y_experiment - yHat;
sigma_sqd = residuals'*residuals/rows;
se_iv = sqrt(sigma_sqd * inv(X_Endogeneous' * projection * X_Endogeneous));
ci_95th_up = IV_estimates(1,1) + se_iv*z_stat;
ci_95th_low = IV_estimates(1,1) - se_iv*z_stat;
CI = [ci_95th_low, ci_95th_up];



end

