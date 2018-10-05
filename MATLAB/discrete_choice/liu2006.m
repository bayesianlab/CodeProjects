function [betabar, stoB, R0bar, acceptrate, r0Elems, stoR0 ] = liu2006(y,X, b0, B0,...
    wishartDf, D0, R0, Sims, burnin, r0indxs)
% y is expected as [y11,..., y1T; 
%                   y21,...,y2T]
% Dimension sizes needed
% X is longitudnal data
% subject Xij = [1, x(i,1,...J)]

[r,c] = size(X);
[K,~]= size(R0);
SampleSize = r/K;
% Prior initialization
B=b0;
B0inv = inv(B0);
BpriorsPre = B0inv*b0;
z = y;
R0avg = R0;

% Storage containers and intialize local vars. 
lu = log(unifrnd(0,1,Sims,1));
s1 = zeros(c,c);
s1eye = eye(c,c);
r0i = eye(K);
s2= zeros(c,1);
tempSum1 = s1;
tempSum2=s2;
accept = 0;
stoB = zeros(Sims, c);
trackingNum = size(r0indxs,1);
r0Elems = zeros(Sims-burnin, trackingNum);
postDraws = 0;
accept = 0;
stoR0 = zeros(K, K, Sims-burnin);

for i = 1 : Sims
    mu = X*B;
    reshapedmu = reshape(mu, K, SampleSize);
    z = updateLatentZ(y,reshapedmu, R0);
    % Correlation Matrix Part
    ystar = D0*(z - reshapedmu);
    WishartParameter = ystar*ystar';
    dw = diag(WishartParameter);
    idwhalf = dw.^(-.5);
    Sstar = diag(idwhalf) * WishartParameter * diag(idwhalf);
    canW = iwishrnd(Sstar, wishartDf);
    d0 = diag(canW).^(.5);
    canD = diag(d0);
    canD0i = diag(d0.^(-1));
    canR = canD0i * canW * canD0i;
    mhprob = min(0,logdet(canR) - logdet(R0));
