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

smoothedkernel(mu,S,.1,10000)
ghk(10000, 3, mu', S)
sternSimulator(10000,mu,S)


