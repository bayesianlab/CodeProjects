function [] = crbMLSimulator(N, Sims, batches)


crb = zeros(Sims, 1);
X = normrnd(1,1,N,2);
er = normrnd(0,1,N,1);
y = X*[.25;.45]  + er;
XpX = (X'*X);
XpXinv = (XpX)^(-1);
Xpy = X'*y;
bMLE = XpX^(-1) * Xpy;
e = y - X*bMLE;
sSqd = (e'*e)/N;
thetaMLE = [sSqd; bMLE];
invFisher = [(2*sSqd^2)/N, [0,0];...
    [0;0], sSqd*XpXinv];

for i = 1:Sims
    samp = tmvnGibbsSampler(0,Inf, thetaMLE', invFisher, 100,10, [0,0,0]);
    [z, fz] = crbMarginalLikelihood(0, Inf, thetaMLE', inv(invFisher), samp, 2000);
    b = z(2:3)';
    s = z(1);
    crb(i) = lrLikelihood(y,X, b, s)  + log(mvnpdf(b', [0,0], eye(2))) + ...
        log(invgampdf(s, 3,6)) - log(prod(fz,2));
end
crbStd = batchMeans(batches, crb);
crbMean= mean(crb);
fprintf('CRB mean, std: %f, %f\n', crbMean, crbStd);

WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
