function[negLogLikelihood, gradientNeg] = gammaNegLogLikelihood(params, Y)
% params = vector of parameters of gamma function (alpha, beta)
% X random draws on gamma function
% RETURNS value of negative log likelihood function and gradient
alpha = params(1);
beta = params(2);
lenY = length(Y);
sumLogYis = sum(log(Y));
sumYis = sum(Y);
yBar = mean(Y);
% From the log likelihood function the partial derivative of L(alpha,beta)
% w.r.t. beta is solvable in closed form, as opposed to the case with alpha
% The MLE for beta is (1/alpha)*yBar, yBar being the mean. 
betaHat = (1/alpha) * yBar;
% The log likelihood function. 
logLikelihood = -lenY * (log(gamma(alpha)) + alpha * log(betaHat)) + ...
    ((alpha - 1) * sumLogYis) - ((1/beta) * sumYis) ;
negLogLikelihood = - logLikelihood ;
% p. deriv. w.r.t. beta.
gradBeta = -((lenY * alpha)/ beta) + ((1/beta^2)* sumYis) ;
% p. deriv. w.r.t. alpha
gradAlpha = sumLogYis - lenY * (log(beta) + psi(alpha));
% return negative of the gradient.
gradientNeg = - [gradAlpha; gradBeta] ;
end

