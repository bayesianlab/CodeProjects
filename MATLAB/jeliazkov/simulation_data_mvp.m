% Simulation Data multivariate probit
clear; clc;
% seed = 1;
% rng(seed);
J = 3;
N = 1;
rho = -.7;
sigma = eye(J);
sigma = createSigma(-.7, J);
C = chol(sigma, 'lower');
mu1 = [0, .5, 1];
epsilon = mvnrnd([0,0,0], sigma, N);
y = ones(N, J);

mu16 = kron(ones(1,2), mu1);
sigma2 = createSigma(rho, 6);
mu2 = [-.5, 0, .5];


