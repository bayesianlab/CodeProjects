clear;
clc;

N = 40000;
a = 0;
b = Inf;
alpha = 1;
beta = .5;
mu = -3;
sigmaSqd = 16;
sigma = sqrt(sigmaSqd);

proposals = gamrnd(alpha, 1/beta, N,1);
weights = normpdf(proposals, mu, sigmaSqd) ./ ...
    gampdf(proposals, alpha, 1/beta);
muHat = mean(proposals.*weights);
secondMoment = mean((proposals.^2) .* weights);
sigHat = sqrt(secondMoment - muHat^2);

fprintf('\n\tImportance Sampling Method Results\n')
fprintf('E[Y] =                         %.4f\n', muHat)

fprintf('E[Y^2] =                       %.4f\n', secondMoment)
fprintf('(E[Y^2] - E[Y]^2)^(1/2) =      %.4f\n', sigHat)
fprintf('Analytical expected value:     %.4f\n',...
    truncNormalMean(0,inf,mu,sigma))
fprintf('Analytical standard deviation: %.4f\n',...
    sqrt(truncNormalVar(a,b,mu,sigma)))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = 40000;
a = 0;
b = Inf;
alpha = .5;
beta = 1;
mu = -3;
sigmaSqd = 16;
sigma = sqrt(sigmaSqd);

proposals = gamrnd(alpha, 1/beta, N,1);
weights = normpdf(proposals, mu, sigmaSqd) ./ ...
    gampdf(proposals, alpha, 1/beta);
muHat = mean(proposals.*weights);
secondMoment = mean((proposals.^2) .* weights);
sigHat = sqrt(secondMoment - muHat^2);
fprintf('\n\tImportance Sampling Method Results\n')
fprintf('E[Y] =                         %.4f\n', muHat)

fprintf('E[Y^2] =                       %.4f\n', secondMoment)
fprintf('(E[Y^2] - E[Y]^2)^(1/2) =      %.4f\n', sigHat)
fprintf('Analytical expected value:     %.4f\n',...
    truncNormalMean(0,inf,mu,sigma))
fprintf('Analytical standard deviation: %.4f\n',...
    sqrt(truncNormalVar(a,b,mu,sigma)))





