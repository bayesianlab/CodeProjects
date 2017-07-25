function [] = crbMLSimulator(N, coefs, Sims, batches, seed)

rng(seed);
crb = zeros(Sims, 1);
p = length(coefs);
X = normrnd(1,1,N,p);
er = normrnd(0,1,N,1);
y = X*coefs  + er;
XpX = (X'*X);
XpXinv = (XpX)^(-1);
Xpy = X'*y;
bMLE = XpX^(-1) * Xpy;
e = y - X*bMLE;
sSqd = (e'*e)/(N-p);  
thetaMLE = [sSqd; bMLE];
empty = zeros(p,1);
invFisher = [(2*sSqd^2)/N, empty' ;...
        empty, sSqd*XpXinv];

for i = 1:Sims
    samp = tmvnGibbsSampler(0,Inf, thetaMLE', invFisher, 550,50, zeros(1,p+1));
    [z, fz] = crbMarginalLikelihood(0, Inf, thetaMLE', inv(invFisher), samp, 500);
    b = z(2:p+1)';
    s = z(1);
    crb(i) = lrLikelihood(y,X, b, s)  + logmvnpdf(b', empty', eye(p)) + ...
        loginvgampdf(s, 3,6) - log(prod(fz,2));
end
crbStd = batchMeans(batches, crb);
crbMean= mean(crb);
fprintf('CRB mean, std: %f, %f\n', crbMean, crbStd);


