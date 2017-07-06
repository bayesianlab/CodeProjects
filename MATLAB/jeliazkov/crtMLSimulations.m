function [  ] = crtMLSimulations(N, Sims, batches)

crt= zeros(Sims, 1);
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
    
    [K, z] = crtMarginalLikelihood(0, Inf, thetaMLE', invFisher, 1100, 100,...
        [0, 0, 0]);
    b = z(2:3)';
    s = z(1);
    crt(i) = lrLikelihood(y,x, b, s)...
        + logmvnpdf(b', [0,0], eye(2))...
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

