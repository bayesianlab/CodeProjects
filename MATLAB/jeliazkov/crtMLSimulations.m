function [  ] = crtMLSimulations(N, coefs, Sims, batches,seed)
rng(seed);
crt1= zeros(Sims, 1);
crt2 = zeros(Sims, 1);
p = length(coefs);
X = normrnd(1,1,N,p);
er = normrnd(0,.5,N,1);
y = X*coefs  + er;
XpX = X'*X;
XpXinv = (XpX)^(-1);
Xpy = X'*y;
bMLE = XpX^(-1) * Xpy;
e = y - X*bMLE;
sSqd = (e'*e)/(N-p);  
thetaMLE = [sSqd; bMLE];
empty = zeros(p,1);
invFisher = [(2*sSqd^2)/N, empty' ;...
        empty, sSqd.*XpXinv];
    
for i = 1:Sims
%     [K, z] = crtML(0, Inf, thetaMLE', invFisher, 2100, 100,...
%         thetaMLE');
        [K2, z2] = crtMarginalLikelihood(0, Inf, thetaMLE', invFisher, 2100, 100,...
        thetaMLE');
%     b = z(2:p+1)';
%     s = z(1);
%     crt1(i) = lrLikelihood(y,X, b, s)...
%         + logmvnpdf(b', empty', eye(p))...
%         + loginvgampdf(s, 3,6)...
%         - log(mean(prod(K,2)));  
    
    b = z2(2:p+1)';
    s = z2(1);
    crt2(i) = lrLikelihood(y,X, b, s)...
        + logmvnpdf(b', empty', eye(p))...
        + loginvgampdf(s, 3,6)...
        - log(mean(prod(K2,2)));  

end
crtStd = batchMeans(batches, crt1);
crtMean = mean(crt1);
fprintf('CRT mean, std: %f, %f\n', crtMean, crtStd);
crtStd = batchMeans(batches, crt2);
crtMean = mean(crt2);
fprintf('CRT mean, std: %f, %f\n', crtMean, crtStd);

end

