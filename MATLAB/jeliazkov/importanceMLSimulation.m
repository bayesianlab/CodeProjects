function [] = importanceMLSimulation(N, Sims, batches)

importance = zeros(Sims, 1);
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
    importance(i) = lrmlRestricted(0, Inf, y, x, 3, 6, thetaMLE, invFisher, 1100, 100);
end
importanceStd = batchMeans(batches, importance);
importanceMean = mean(importance);
fprintf('Importance sampling mean, std: %f, %f\n', importanceMean, importanceStd);

WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
