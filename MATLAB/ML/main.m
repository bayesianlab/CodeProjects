clear; clc;
leftTruncation(8);
twoSided(1,2);
truncNormalRand(10, Inf, 9, .01);
truncNormalRand(-Inf, 10, 11, .01);
a = [0,0, 0]';
b = [Inf, Inf, Inf]';
mu = [0,.5,1]';
S = createSigma(-.7, 3);
N = 5;
bn = 1;


% mean(tmultnormrnd(a,b,mu,S,10000,zeros(3,1)))
% mean(tmultnormrndEta(a,b,mu,S,10000))
% mean(studentTGeweke91(a,b,mu,S,10, 10000,100))
% mean(ghkT(a,b,mu,S,10,10000))
% [x,y] = ghkT(a,b,mu,S,10,10);
impT(a,b, mu,S, 3, 1,2, N,  0,0,0,0)


