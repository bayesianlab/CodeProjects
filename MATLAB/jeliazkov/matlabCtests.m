clear;
clc;

N = 10000;
X = normrnd(0,1,N,4);
[N,p] = size(X)
er = normrnd(0,1,N,1);
coefs = [ .75, .55, .35, .15]';
y = X*coefs  + er;
XpX = (X'*X);
XpXinv = (XpX)^(-1);
Xpy = X'*y;
bMLE = XpX^(-1) * Xpy;
e = y - X*bMLE;
sSqd = (e'*e)/(N);  
thetaMLE = [sSqd; bMLE];
empty = zeros(4,1);
invFisher = [(2*sSqd^2)/N, empty' ;...
        empty, sSqd*XpXinv];
 
format long g
theta = ghkGibbsSampler(0, Inf, thetaMLE', invFisher, 10);

logmvnpdf(theta(:,2:5), zeros(1,4), eye(4));
mean(loginvgampdf(theta(:,1), 3,6)');
std(loginvgampdf(theta(:,1), 3,6)');

lrLikelihood(y, X, theta(:,2:5)', theta(:,1)')
