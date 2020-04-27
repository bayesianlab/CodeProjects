%% Homework 1
clear;clc;
rng(11)
N=250;
K=4;
X = [ones(N,1), normrnd(0,5, N,K-1)];
beta = ones(4,1);
sigma2 = 1;
y=X*beta + normrnd(0,sigma2, N,1);
LL = @(guess) negLikelihood(guess, y,X);
fminunc(LL, [beta;sigma2])