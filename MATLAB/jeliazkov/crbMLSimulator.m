function [] = crbMLSimulator(N, Sims, batches)


crb = zeros(Sims, 1);
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
    samp = tmvnGibbsSampler(0,Inf, thetaMLE', invFisher, 100,10, [0,0,0]);
    [z, fz] = crbMarginalLikelihood(0, Inf, thetaMLE', inv(invFisher), samp, 2000);
    b = z(2:3)';
    s = z(1);
    crb(i) = lrLikelihood(y,x, b, s)  + log(mvnpdf(b', [0,0], eye(2))) + ...
        log(invgampdf(s, 3,6)) - log(prod(fz,2));
end
crbStd = batchMeans(batches, crb);
crbMean= mean(crb);
fprintf('CRB mean, std: %f, %f\n', crbMean, crbStd);

WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
