clear;clc;
T = 250;
K = 4; 
X = [ones(T,1), normrnd(0,5,T,K-1)];
beta = ones(K,1);
y = X*beta + normrnd(0,1,T,1);


Sims = 11000;
burnin = 1000;
b0 = zeros(K,1);
B0 = 10.*eye(K);
ig_parama0 = 6;
ig_paramb0 = 4; 

[storeBeta, storeSig2] = LRGibbs(y, X, b0, B0, ig_parama0, ig_paramb0, Sims, burnin);
mean(storeBeta,2)
std(storeBeta, [],2)