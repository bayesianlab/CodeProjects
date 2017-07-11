function [  ] = crtMLSimulations(N, coefs, Sims, batches,seed)
rng(seed);
crt= zeros(Sims, 1);
p = length(coefs);
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
    [K, z] = crtMarginalLikelihood(0, Inf, thetaMLE', invFisher, 2200, 200,...
        zeros(1,p+1));
    b = z(2:3)';
    s = z(1);
    crt(i) = lrLikelihood(y,X, b, s)...
        + logmvnpdf(b', empty', eye(2))...
        + loginvgampdf(s, 3,6)...
        - log(mean(prod(K,2)));  
end

crtStd = batchMeans(batches, crt);
crtMean = mean(crt);
fprintf('CRT mean, std: %f, %f\n', crtMean, crtStd);

WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);

end

