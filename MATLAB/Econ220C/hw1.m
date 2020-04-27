%% Homework 1
clear;clc;
rng(11)
N=250;
K=4;
X = [ones(N,1), normrnd(0,5, N,K-1)];
beta = ones(4,1);
sigma2 = 1;
y=X*beta + normrnd(0,sigma2, N,1);

%% OLS Estimates 
bls = (X'*X)\(X'*y);
e = (1/sqrt(N-K))*(y-X*bls);
sebls = sqrt(diag( e'*e.*inv(X'*X) ));
bls = round(bls,3);
sebls = round(sebls,3);

%% Maximum Likelihood
negLL = @(b)  .5*(N*log(2*pi*b(end)) +  (y-X*b(1:end-1))'*(y-X*b(1:end-1))/b(end));
options = optimoptions(@fminunc, 'FiniteDifferenceType', 'forward', 'display', 'off');
[bmle, ~,~,~,~,H] = fminunc(negLL, [beta;sigma2], options);
H
-H
semle = sqrt(diag(-H\eye(K+1)));

%% Bayes Estimation
b0 = zeros(K,1);
B0 = 100*eye(K);
nu0 = 6;
d0 = 4;
Sims = 11000;
burnin = 1000;
[storeb, stores2] = SimpleGibbsLS(y,X, b0, B0, nu0, d0, Sims, burnin);
betaBayes = round(mean(storeb,2),3);
sdBetaBayes = round(std(storeb,[],2),3);

%% Results Compared 
betamle = round(bmle(1:end-1),3);
semle = round(semle(1:end-1),3);
table(bls, sebls, betamle, semle, betaBayes, sdBetaBayes)

%% Expectations and Variability of estimators
% The expectaions in OLS and MLE depend on data not yet observed. 
% In OLS the expectation is taken over the distribution of the beta OLS
% but this distribution may not exist, for instance, if the experiment is not 
% repeatable. The OLS estimator could be far into the tail in this case and it 
% would not be known. The MLE estimator is similar. The Asymptotic variance
% and mean may not be met in finite samples. Only as the limit of the sample
% size goes to infinity does the Asymptotic behavior of the CRLB actually 
% achieved. In small samples the variance could be quite large, and it is doubtful
% that it is close to the CRLB in most cases. 
% The Bayes estimator only averages over the posterior distribution, which is derived
% conditional only on the data observed. The intervals are more intuitive than the 
% corresponding frequentist intervals, which only give confidence to the procedure
% in which the estimator was calculated. The confidence intervals do not give 
% a probability of the true parameter lying within their domain in the Frequentist setting,
% but Bayesian credible intervals do have a probabilistic interpretation. 