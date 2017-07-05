function [] = arkMLSimulator()

N = 50;
Sims = 1000;
ark = zeros(Sims, 1);
for i = 1:Sims
    X = normrnd(1,1, N,2);
    y = X*[.25;.45]  + normrnd(0,1, N,1);
    [N, ~] = size(X);
    XpX = (X'*X);
    XpXinv = (XpX)^(-1);
    Xpy = X'*y;
    bMLE = XpX^(-1) * Xpy;
    e = y - X*bMLE;
    sSqd = (e'*e)/N;
    thetaMLE = [sSqd; bMLE];
    invFisher = [(2*sSqd^2)/N, [0,0];...
        [0;0], sSqd*XpXinv];
    [K, z] = arkMarginalLikelihood(0, Inf, thetaMLE', invFisher, 2000);
    b = z(2:3)';
    s = z(1);
    ark(i) = lrLikelihood(y,X, b, s)  + log(mvnpdf(b', [0,0], eye(2))) +...
        log(invgampdf(s, 3,6)) - log(mean(prod(K,2)));
end
arkStd = batchMeans(15, ark);
arkMean = mean(ark);
fprintf('ARK mean, std: %f, %f\n', arkMean, arkStd);

WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
