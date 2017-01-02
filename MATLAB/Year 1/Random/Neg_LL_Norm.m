function [val, grad] = Neg_LL_Norm(theta, x)
% Negative Log Likelihood function for normally distributed data.
% input: 2 by 1 vector theta = (mu, sigm?2), and T by 1 vector of randomly
% generated data from a normal distribution
% output: value of the negative log-likelihood function evaluated at theta,
% as well as the gradient
% define mu and siq sqr, get dimension, T, of data vector
mu = theta(1);
sig_sqr = theta(2);
T = length(x);
%% Define Log-Likelihood
% It can be easier to break up large quantities into smaller ones for clarity
sum_x = sum(x); % sums all of the elements of x
sum_x2 = sum(x.^2); % notice the ``.?'' means element wise squaring
sums_term = sum_x2 - 2*mu*sum_x + T*mu^2;
% actual value of the Log-Likelihood (pi is a constant in MATLAB)
LL = -(T/2)*(log(2*pi) + log(sig_sqr)) - (1/(2*sig_sqr))*sums_term;
% negative of the Log Likelihood returned by the function
val = -LL;
%% Define gradient
%partial derivative of LL w.r.t. mu
g_mu = sum_x/sig_sqr - T*mu/sig_sqr;
% partial derivative of LL w.r.t. sigma?2
g_sig_sqr = -T/(2*sig_sqr) + (1/(2*sig_sqr^2))*sums_term;
% negative of the gradient vector returned by function
grad = - [g_mu; g_sig_sqr];
end