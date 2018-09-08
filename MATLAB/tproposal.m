% t proposal
clear;clc;
N = 1000;
nu = 5;
sims = 2500;
empty = zeros(4,1);
priorMean = zeros(5,1);
priorVar = 10*eye(5);
thetaStore = zeros(sims, 5);
w = sqrt(chi2rnd(nu, [sims,1])./nu);

beta = [1.2, .5,.6, .7]';
x = normrnd(0,1, [N,3]);
x = [ones(N,1), x];
y = x*beta + normrnd(0,1,N,1);
xpxinv = inv(x'*x);
P = eye(N) - x*xpxinv*x';
sigmahatsqd = (y'*P*y)/N;

thetaHat = [(xpxinv*x'*y)', sigmahatsqd]';
ThetaHat = [sigmahatsqd*xpxinv, empty; empty', 2*(sigmahatsqd^2)/N];

old = mvnrnd(thetaHat', ThetaHat, 1);
for i = 1:sims
    propose = mvnrnd(thetaHat',ThetaHat, 1)./w(i);
    alpha = min(0, (lrLikelihood(y, x, propose(1:4)', propose(5)) + ...
                    logmvnpdf(propose, priorMean', priorVar) + ...
                    logtpdf(old', thetaHat, ThetaHat, nu) ) - ...
                   (lrLikelihood(y, x, old(1:4)',old(5)) + ...
                    logmvnpdf(old(1:5), priorMean', priorVar) + ...
                    logtpdf(propose', thetaHat, ThetaHat, nu)) );
    logu = log(unifrnd(0,1,1));
    if logu < alpha
        thetaStore(i, :) = propose;
        old = propose;
    else
       thetaStore(i, :) = old;
    end
end
thetaStore = thetaStore(.1*sims:sims, :);
thetaHat'
mean(thetaStore)
