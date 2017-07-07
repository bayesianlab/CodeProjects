function [] = importanceMLSimulation(N, coefs, Sims, batches)
% coefs as column
p = length(coefs);
importance = zeros(Sims, 1);
X = normrnd(1,1,N,p);
er = normrnd(0,1,N,1);
y = X*coefs  + er;
XpX = (X'*X);
XpXinv = (XpX)^(-1);
Xpy = X'*y;
bMLE = XpX^(-1) * Xpy;
e = y - X*bMLE;
sSqd = (e'*e)/N;  
thetaMLE = [sSqd; bMLE];
empty = zeros(p,1);
invFisher = [(2*sSqd^2)/N, empty' ;...
        empty, sSqd*XpXinv];
for i = 1:Sims
    importance(i) = lrmlRestricted(0, Inf, y, X, 3, 6, thetaMLE, invFisher, 1100, 100);
end
importanceStd = batchMeans(batches, importance);
importanceMean = mean(importance);
fprintf('Importance sampling mean, std: %f, %f\n', importanceMean, importanceStd);

WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
