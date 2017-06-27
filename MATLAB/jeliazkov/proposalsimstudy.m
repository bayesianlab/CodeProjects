clear, clc;
% rng(1)


N = 100;
X = normrnd(1,1, N,2);
y = X*[.25;.45]  + normrnd(0,1, N,1);

[N, p] = size(X);
XpX = (X'*X);
XpXinv = (XpX)^(-1);
Xpy = X'*y;
bMLE = XpX^(-1) * Xpy;
e = y - X*bMLE;
sSqd = (e'*e)/N;
thetaMLE = [sSqd; bMLE];

invFisher = [(2*sSqd^2)/N, [0,0];...
    [0;0], sSqd*XpXinv];
variances = diag(invFisher);
C = chol(invFisher, 'lower');
Draws = 101;

z = askGibbs(0,Inf, thetaMLE, invFisher, Draws, 1);
theta = thetaMLE + C*z';

betaDraws = theta(2:3,:);
sigmaDraws = theta(1,:);
A = tnormpdf(0,Inf, sSqd, sqrt(variances(1)), sigmaDraws');
B = tnormpdf(0,Inf, thetaMLE(2,1), sqrt(variances(2)), betaDraws(1,:)');
C = tnormpdf(0,Inf, thetaMLE(3,1), sqrt(variances(3)), betaDraws(2,:)');
hTheta = prod([A,B,C],2);

importance = mean(lrLikelihood(y,X,betaDraws, sigmaDraws) +...
    log(mvnpdf(betaDraws',[0,0], eye(2))) +...
    log(invgampdf(sigmaDraws, 3,6)) -...
    log(hTheta))


samp = tmvnGibbsSampler(0,Inf, thetaMLE', invFisher, 100,10, [0,0,0]);

[z, fz] = crbMarginalLikelihood(0, Inf, thetaMLE', inv(invFisher), samp, 100);
b = z(2:3)';
s = z(1);
crb = lrLikelihood(y,X, b, s)  + log(mvnpdf(b', [0,0], eye(2))) + ...
    log(invgampdf(s, 3,6)) - log(prod(fz,2))

K = crtMarginalLikelihood(0,Inf, thetaMLE', invFisher, 100, 10, [0,0,0]);
crt = lrLikelihood(y,X, b, s)  + log(mvnpdf(b', [0,0], eye(2))) +...
    log(invgampdf(s, 3,6)) - log(mean(prod(K,2)))

K = arkMarginalLikelihood(0, Inf, thetaMLE', invFisher, 1000);
ark = lrLikelihood(y,X, b, s)  + log(mvnpdf(b', [0,0], eye(2))) +...
    log(invgampdf(s, 3,6)) - log(mean(prod(K,2)))

K = askMarginalLikelihood(0, Inf, thetaMLE', invFisher, 100,10);
ask = lrLikelihood(y,X, b, s)  + log(mvnpdf(b', [0,0], eye(2))) +...
    log(invgampdf(s, 3,6)) - log(mean(prod(K,2)))


