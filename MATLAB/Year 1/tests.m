clear
clc

null = zeros(2,1);
alphaLev = .05;
alt = 2;

y = normrnd(0,1, 100,1);
x = normrnd(0,1, 100,1);
c = ones(100,1);

a = fitlm(x,y);
a

x = [c,x];
regress(y,x)
betaLS(x,y, [0;0], .05, 2, 1)

[walk1, walk2, w1Lag, w2Lag, c]= generateWalks( 100 );
X = [ walk2, c];
[~, ~, tStats, tCrit] = betaLS( X, walk1, null, alphaLev, ...
    alt, 0);

[e, tstat, tcrit] = vreg([walk1, walk2], 1, zeros(3,1), alphaLev, 2,1);
