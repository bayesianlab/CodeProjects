clear;clc;
mu = [0,1];
sig = [1, .5;
    .5, 1]; 
S = 10;
a0 =3;
L = chol(sig, 'lower');

Z = normrnd(0,1, S,2);
W = (mu' + L*Z')'
T = (mu' + (L*Z')./ (sqrt(chi2rnd(S+a0)/(S+a0))))'

hold on
scatter(W(:,1),W(:,2))
scatter(T(:,1),T(:,2))

