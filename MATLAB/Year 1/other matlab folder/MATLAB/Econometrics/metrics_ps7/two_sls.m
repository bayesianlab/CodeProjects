%% 2 SLS Simulation
% y = XB + e, is the DGP. 
% We will demonstrate the problems with using a weak instrument. 
% The assumption E(ZX) = 0 will not be satisfied, that is, Z will
% not explain or be correlated with X's variation. We will assume the
% other assumption holds, E(Ze) = 0. We must build a DGP such that
% our instrument is not correlated with X. 
clear
clc
mu = 0;
sigma = 1;
rows = 1000;
columns = 1;
beta = 6.5;
z_stat = 1.96;
errorTerm = normrnd(mu,sigma, rows, columns);
endogenous_error = errorTerm + normrnd(mu,sigma,rows,columns);

% Some variation of the error term is explainable with our 
% covariate X, a problem for assumptions of OLS. This justifies using
% instrumental variables. The instrument will remove the correlation
% of X with e.
weak_instrument = normrnd(mu,sigma,rows,columns);

% This will be our one endogenous variable
X_Endogeneous =  .3*weak_instrument + normrnd(mu,sigma, rows, columns)...
        + endogenous_error;
X_Exogeneous = normrnd(mu,sigma, rows, columns);
X_Mat = [X_Endogeneous X_Exogeneous];

% If we want to examine when we have a good estimate this will be the
% X variable to use. 
X_Correlated =  weak_instrument + errorTerm;

% The correlation is high between X and the error term, but almost 
% zero between the instrument and X. This makes Z a weak instrument.
% Besides this the usual assumptions are satisfied for 2SLS. 
x_uncorr_with_error = corr(X_Endogeneous, errorTerm);
str = sprintf(['Correlation Endogeneous With Error\n',...
                '(Should be correlated): %f \n'], x_uncorr_with_error);
disp(str)
instrument_with_error = corr(weak_instrument, errorTerm);
str = sprintf('Correlation Instrument \n With Error (Should be 0) %f\n',...
    instrument_with_error);
disp(str)
x_uncorr_with_instrument = corr(X_Endogeneous, weak_instrument);
str = sprintf(['Correlation Endogeneous With Instrument\n',...
    'This should be  close to` 0 because\n it is weak: %f\n'], instrument_with_error);
disp(str)


% Very little of x is explained by instrument. 
olsEstimators_instrument_on_x_uncorr = betaOLS(weak_instrument,X_Endogeneous);
str = sprintf(['Another check for the strength of our\n instrument',...
    ' is running a regreession.\n If the coefficient is small',...
    ' then we know\n it is a weak instrument.\n OLS Estimates:  %f\n'],...
    olsEstimators_instrument_on_x_uncorr);
disp(str)

str = sprintf(['On the other hand it will be useful to\n check',...
    ' when there is a strong instrument.\n']);
disp(str)


% To see the difference IV makes when the instrument 
% is very correlated to X, OLS estimates are compared here to
% instrumental variables estimation. 
% OLS returns estimates that are way off: 
y_cor = X_Correlated*beta + errorTerm;
goodEstimate = iv_estimator(weak_instrument,X_Correlated, y_cor);
badEstimate = betaOLS(X_Correlated, y_cor);
str = sprintf(['OLS way off from the true beta (%.2f)\n compared to IV',...
    ' estimation. \n OLS: %.2f\n IV: %.2f\n '],...
    beta, badEstimate, goodEstimate);
disp(str)

%% For one instrument
betaTrue = [5.5; 3.5];
mcSim = 100;
store_results_z_weak = zeros(length(mcSim),1);
store_CI = zeros(length(mcSim),2);
store_results_normalOLS = zeros(length(mcSim),1);
for index = 1:mcSim
    % IV Esitmates 
    [iv, resid, ols_est, CI] = iv_sim(mu,sigma, rows, columns,betaTrue,...
        1);
    store_results_z_weak(index,1) = iv;
    store_CI(index,1:2) = CI;
    
    % OLS Esitmates
    store_results_normalOLS(index, 1) = ols_est;
end
avg_ivs = mean(store_results_z_weak);
avg_ols = mean(store_results_normalOLS);
str = sprintf(['Display the mean of the vector of iv\n estimates:',...
    '\n %.2f \n Compare with OLS: \n %.2f\n',...
   'Compare with true parameters:\n %.2f\n'], avg_ivs,...
   avg_ols, betaTrue(1,1));
disp(str)
ols_ivs = [store_results_normalOLS, store_results_z_weak];
hist(ols_ivs)
legend('OLS Estimators', 'Weak IV Estimator')
title('True Beta is 5.5')
figure
store_CI_and_weaks = [store_CI, store_results_z_weak];
plot(store_CI_and_weaks)
hold on
plot(1:mcSim, ones(1,mcSim)*betaTrue(1,1))
legend('Lower Bound','Upper Bound','Estimator', 'True Beta')

%% Coverage Probabilities
cnt = 0;
for i = 1:mcSim
    if betaTrue(1,1) >= store_CI(i,2) | betaTrue(1,1) <= store_CI(i,1)
        cnt = cnt + 1;
    end
end
coverage_prob = 1 - cnt/mcSim;
str = sprintf(['The coverage probability (percent of time)\n the true',...
    ' beta value was in the interval\n is: \n %.3f percent'],...
    100*coverage_prob);
disp(str)



