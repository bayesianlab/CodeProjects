clear;
clc;

N = 2000;
alpha = 1;
beta = .5;
mu = -3;
sigmaSqd = 16;
sigma = 4;
bins = 60;

% tnormMean = @(a, b, mu, sigma) mu + ( ( normpdf( (a-mu)/sigma ) -...
%     normpdf( (b-mu)/sigma ) ) / ( normcdf( (b-mu)/sigma ) -...
%     normcdf( (a-mu)/sigma ) ) ) * sigma;

[x1, sup] = arTruncNormal(alpha, beta, mu, sigmaSqd, N);
fprintf('\n\tAccept-Reject Method Results\n')
fprintf('Proposal Gamma(%.4f,%.4f)\n', alpha, beta)
fprintf('Bounding constant:          \t%.4f\n', sup)
fprintf('Analytical expected value: \t%.4f\n', truncNormalMean(0,inf,mu,sigma))
fprintf('Mean of sample:            \t%.4f\n', mean(x1))
fprintf('St. dev. of sample:        \t%.4f\n', std(x1))
figure(1)
hold on
histogram(x1, bins)
histogram(normrnd(mu, sigma, N,1), bins)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = 2000;
alpha = .5;
beta = 1;
mu = -3;
sigmaSqd = 16;
sigma = 4;
bins = 60;
[x2, sup] = arTruncNormal(alpha, beta, mu, sigmaSqd, N);
fprintf('\n\tAccept-Reject Method Results\n')
fprintf('Proposal Gamma(%.4f,%.4f)\n', alpha, beta)
fprintf('Bounding constant:          \t%.4f\n', sup)
fprintf('Analytical expected value: \t%.4f\n', truncNormalMean(0,inf,mu,sigma))
fprintf('Mean of sample:            \t%.4f\n', mean(x2))
fprintf('St. dev. of sample:        \t%.4f\n', std(x2))
figure(2)
hold on
histogram(x2, bins)
histogram(normrnd(mu, sigma, N,1), bins)
