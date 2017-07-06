function [] = arkMLSimulator(N, Sims, batches)

ark = zeros(Sims, 1);
X = normrnd(1,1,N,2, Sims);
er = normrnd(0,1,N, Sims);
for i = 1:Sims
    x = X(:,:, i);
    y = x*[.25;.45]  + er(:,i);
    [N, ~] = size(x);
    XpX = (x'*x);
    XpXinv = (XpX)^(-1);
    Xpy = x'*y;
    bMLE = XpX^(-1) * Xpy;
    e = y - x*bMLE;
    sSqd = (e'*e)/N;
    thetaMLE = [sSqd; bMLE];
    invFisher = [(2*sSqd^2)/N, [0,0];...
        [0;0], sSqd*XpXinv];
    [K, z] = arkMarginalLikelihood(0, Inf, thetaMLE', invFisher, 2000);
    b = z(2:3)';
    s = z(1);
    ark(i) = lrLikelihood(y,x, b, s)  + logmvnpdf(b', [0,0], eye(2)) +...
        loginvgampdf(s, 3,6) - log(mean(prod(K,2)));
end
arkStd = batchMeans(batches, ark);
arkMean = mean(ark);
fprintf('ARK mean, std: %f, %f\n', arkMean, arkStd);

WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
