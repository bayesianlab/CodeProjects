function [Beta_draws,sigma2_draws] = GIBBS_LINEAR(Y,X,ndraws,burn_in,add_constant)

% Purpose: 
% Bayesian inference of classic linear regression model
% -----------------------------------
% Model:
% Yi = Xi * Beta + ui , where ui ~ N(0,s^2)
% -----------------------------------
% Algorithm: 
% Gibbs sampler with Lindley and Smith (1972) proper priors
% Beta ~ N(mu,V), s^2 ~ IG(a,b)
% Conditional posteriors are conjugate normal and inverted gamma respectively.
% Hyperparameters are specified below
% -----------------------------------
% Usage:
% Y = dependent variable (n * 1 vector)
% X = regressors (n * k matrix)
% ndraws = number of draws in MCMC
% burn_in = number of burn-in draws in MCMC
% add_constant = whether to add a constant to X (default = 0)
% -----------------------------------
% Returns:
% Beta_draws = posterior draws of coefficients corresponding to the k regressors
% sigma2_draws = posterior draws of variance of disturbances
% 
% Written by Hang Qian, Iowa State University
% Contact me:  matlabist@gmail.com


if nargin < 2;    error('Incomplete data.');      end
if nargin < 3;    ndraws = 50000;                                          end
if nargin < 4;    burn_in = ndraws * 0.2;                                  end
if nargin < 5;    add_constant = 0;                                  end

try
    JustTest = gamrnd(3,1);
catch
    disp(' ')
    disp('Oooopse, Matlab statistics toolbox is not installed.')
    disp('You may download a compatibility package on my website.')
    disp('http://www.public.iastate.edu/~hqi/toolkit')
    error('Program exits.')
end

[nrow_x,ncol_x] = size(X);
[nrow_y,ncol_y] = size(Y);
if nrow_x < ncol_x;    X = X';    ncol_x = nrow_x;end
if nrow_y < ncol_y;    Y = Y';    ncol_y = nrow_y;end
if ncol_x < ncol_y;    Y_temp = Y;    Y = X;    X = Y_temp;end

[nobs, nreg] = size(X);
if add_constant == 1
    disp('A constant is added to X.')
    X = [ones(nobs,1),X];
    nreg = nreg + 1;
end

% --------------------------------------------------------
% Prior distribution settings
%  Beta ~ N(mu,V)
%  s^2 ~ IG(a,b)
% You may change the hyperparameters here if needed
prior_mu = zeros(nreg,1);
prior_V = 100 * eye(nreg);
prior_a = 3;
prior_b = 2.5;
% --------------------------------------------------------


Beta_draws = zeros(nreg, ndraws - burn_in);
sigma2_draws = zeros(1, ndraws - burn_in);
Beta_use = prior_mu + chol(prior_V)' * randn(nreg,1);
sigma2_use = 1 / gamrnd(prior_a, prior_b);

XX = X' * X;
XY = X' * Y;
inv_prior_V = inv(prior_V);
gam_a = nobs / 2 + prior_a;
rv_gamma = gamrnd(gam_a,2,1,ndraws);


H_status_bar = waitbar(0,'MCMC in progress    0%');
percentage = floor(ndraws / 100);
for r = 1:ndraws
        
    if mod(r,percentage) == 0
        waitbar(r / ndraws,H_status_bar,['MCMC in progress    ',num2str(floor(r / ndraws * 100)),'%']);
    end
        
    % |. ~ N[inv(X' * inv() * X) * (X' * inv()Y + inv(V) * mu),inv(X' * inv() * X)]
    beta_D = inv(XX / sigma2_use + inv_prior_V);
    beta_d = XY / sigma2_use + inv_prior_V * prior_mu;
    P = chol(beta_D);
    Beta_use = beta_D * beta_d + P' * randn(nreg,1);
       
 
    % ^2|. ~ IG[n / 2 + a, 2b / (b * RSS + 2)]    
    resid = Y - X * Beta_use;
    RSS = resid' * resid;    
    gam_b = 1 / (1 / prior_b + 0.5 * RSS);
    sigma2_use = 1 / (rv_gamma(r) * (gam_b / 2));
    
    if r > burn_in        
        Beta_draws(:, r - burn_in) = Beta_use;
        sigma2_draws(:, r - burn_in) = sigma2_use;
    end
    
end


Beta_mean = mean(Beta_draws,2);
Beta_std = std(Beta_draws,0,2);
sigma2_mean = mean(sigma2_draws,2);
sigma2_std = std(sigma2_draws,0,2);
eval([char([81 72 49 61]),'[87 114 105 116 116 101 110 32 98 121];'])
eval([char([81 72 50 61]),'[32 72 97 110 103 32 81 105 97 110];'])


result = cell(nreg + 2,3);
result(1,:) = {'Coeff.','Post. mean','Post. std'};           
for m = 1:nreg
    result(m + 1,1) = {['C(',num2str(m-add_constant),')']};
    result(m + 1,2:end) = {Beta_mean(m),Beta_std(m)};
end
result(nreg + 2,1) = {'s^2'};
result(nreg + 2,2:end) = {sigma2_mean,sigma2_std};
disp(' ')
disp(result)
fwrite(1, char([QH1,QH2,10,13]))

close(H_status_bar);