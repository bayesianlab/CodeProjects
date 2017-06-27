clear;
clc;
% rng(77, 'twister');
smpsize = 100;
beta1=1;
beta2=.5;
s = .2;
x1 = randn(smpsize,1);
X = [ones(smpsize,1), x1];
y = beta1 + beta2*x1 + sqrt(s)*randn(smpsize,1);

B0 = 4*eye(2);
a0 = 6;
d0 = 5;
beta0 = zeros(1,2);
sigmaInit = 1;
[b,s] = lrGibbs(20000, 100, y, X, beta0, B0, sigmaInit, a0, 1/d0);
betamean = mean(b);
sigmamean = mean(s);

beta0*B0*beta0'
trueMarginalLikelihood = analyticalMarginalLikelihood(X, y, [0;0], B0, a0, 1/d0)
chib = chibsMethod(b, s, X,y, B0, beta0, a0, 1/d0)



% %---------------------------------
% %calculate the ML using Gelfand-Dey method
% %---------------------------------
% mean_vec = [bpoint sigpoint]';
% add_on = zeros(k+1,k+1);
% for i = 1:length(sig_final);
%     temp_term = ([betas_final(i,:) sig_final(i,1)]' - mean_vec)*([betas_final(i,:) sig_final(i,1)]' - mean_vec)';
%     add_on = add_on + temp_term;
% end;
% cov_mat = (1/length(sig_final))*add_on;
% det_cov = det(cov_mat);
% inv_cov = inv(cov_mat);
% np = k+1;
% %loop and calculate the "weight" for each post-convergence draw;
% weight_GD = zeros(length(sig_final),1);
% for i = 1:length(sig_final);
%     parms = [betas_final(i,:) sig_final(i,1)]';
%     critical = (parms - mean_vec)'*inv_cov*(parms-mean_vec);
%     if critical < 11.34; %99th percentile of chisquare (3) density. 
%     prior_b = ((2*pi)^(-k/2))*(sig_final(i,1)^(-k/2))*((det(V_beta))^(-1/2))*exp(-(1/(2*sig_final(i,1)))*betas_final(i,:)*invV_beta*betas_final(i,:)');
%     prior_s = (inv(gamma(a)))*(b^(-a))*(sig_final(i,1)^(-(a+1)))*exp(-1/(b*sig_final(i,1)));
%     likefun = ((2*pi)^(-nobs/2))*(sig_final(i,1)^(-nobs/2))*exp(-(1/(2*sig_final(i,1)))*(y-big_x*betas_final(i,:)')'*(y-big_x*betas_final(i,:)'));
%     f_part = (1/.99)*((2*pi)^(-np/2))*(det_cov^(-1/2))*exp(-.5*(parms - mean_vec)'*inv_cov*(parms-mean_vec));
%     weight_GD(i,1) = f_part/(prior_b*prior_s*likefun);
% end;
% end;
% weights_use = nonzeros(weight_GD); %discard those draws falling outside the region of truncation
% disp('Log Marginal Likelihood via Gelfand-Dey');
% GD_marglike = log(inv(mean(weights_use)))