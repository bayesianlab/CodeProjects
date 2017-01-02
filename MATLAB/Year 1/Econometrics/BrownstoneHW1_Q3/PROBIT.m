
function [estimator,cov_Hessian,ME1] = PROBIT(Y,X)

% Purpose: 
% Estimate Probit model and the marginal effects
% -----------------------------------
% Model:
% Yi* = Xi * Beta + ui , where normalized ui ~ N(0,1)
% Yi* is unobservable. 
% If Yi* > 0, we observe Yi = 1; If Yi* <= 0, we observe Yi = 0
% -----------------------------------
% Algorithm: 
% Maximum likelihood with analytic gradients
% -----------------------------------
% Usage:
% Y = dependent variable (n * 1 vector)
% X = regressors (n * k matrix)
% method_flag = numeric gradients (1), analytic gradients (2, default), analytic Hessian (3)
% -----------------------------------
% Returns:
% estimator = estimator corresponding to the k regressors
% cov_Hessian = covariance matrix of the estimator
% ME1 = marginal effects (average data)
% -----------------------------------
% Notes: 
% Probit model is subject to normalization.
% The variance of disturbances is set to 1, and a constant is added to X.
% 
% Written by Hang Qian, Iowa State University
% Contact me:  matlabist@gmail.com


    
[nobs,nreg] = size(X);
Y_unique = unique(Y);
if length(Y_unique) ~= 2
    disp('Ooopse, dependent variable should be binary.');
    disp('For illustration purpose, Y are grouped to binary data by its mean value')
end
Y = (Y > mean(Y));


add_const = 0;
const_check = all(X==1,1);
if ~any(const_check)
    disp('A constant terms is added to X due to normalization. ')
    X = [ones(nobs,1),X];
    nreg = nreg + 1;
    const_check = [true,const_check];
    add_const = 1;
end


c_initial = (X'*X)\(X'*Y)*(rand-0.5)*10;

[estimator,log_like]=fminunc(@(c)maxLikelihoodProbit(c,Y,X),c_initial);


q = 2*Y - 1;
lamda = q.*pdf('normal',q.*(X*estimator),0,1) ./ cdf('normal',q.*(X*estimator),0,1);
Hessian = -transpose((lamda.*(lamda+X*estimator))*ones(1,nreg).*X)*X;
fisher_info = -Hessian;
cov_Hessian = inv(fisher_info);

% Gradient_indiv = lamda*ones(1,nreg).*X;
% cov_BHHH = inv(Gradient_indiv'*Gradient_indiv);

std_c = sqrt(diag(cov_Hessian));
t_stat = estimator./std_c;

X_bar = mean(X,1);
ME1 = pdf('normal',(X_bar*estimator),0,1) * estimator;
ME1(const_check) = NaN;

disp('------ Regression Results------')
fprintf('   \t Coef. \t Std. \t ME \n')
for m = 1:nreg
    disp([m-add_const, estimator(m), std_c(m), ME1(m)])
end


dummy_check = all((X==1) | (X==0),1) & (~const_check);
for m = 1:nreg
    if dummy_check(m)
        disp(['C(',num2str(m-add_const),') corresponds to binary data.'])
        X_dummy1 = X;
        X_dummy0 = X;
        X_dummy1(:,m) = ones(nobs,1);
        X_dummy0(:,m) = zeros(nobs,1);
        Y_margin_modify_data_bar = cdf('normal',(mean(X_dummy1)*estimator),0,1)-cdf('normal',(mean(X_dummy0)*estimator),0,1);
        Y_margin_modify_indi_bar = mean(cdf('normal',(X_dummy1*estimator),0,1)-cdf('normal',(X_dummy0*estimator),0,1));
        disp(['Adjusted marginal effects (average data) is ',num2str(Y_margin_modify_data_bar)])
        disp(['Adjusted marginal effects (individual average) is ',num2str(Y_margin_modify_indi_bar)])
        disp(' ')
    end
end

disp(['Log likelihood: ',num2str(-log_like)])
disp(' ')


end