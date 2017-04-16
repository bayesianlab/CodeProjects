% Simulation Data multivariate probit
clear; clc;
seed = 1.332;
rng(seed)
J = 3;
N = 1;
rho = -.7;
sigma = eye(J);

sigma = sigma + [0,-.7, .49;
                 -.7, 0, -.7
                 .49, -.7, 0] 
C = chol(sigma, 'lower')
mu1 = [0, .5, 1];
epsilon = mvnrnd([0,0,0], sigma, N);
z = mu1 + epsilon;
y = ones(N, J);

mu2 = [-.5, 0, .5];

