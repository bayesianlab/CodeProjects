function [] = askMLSimulator(N, coefs, sampSize, sampBurn, Sims, batches,seed)

rng(seed);
ask = zeros(Sims, 1);
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
    [K, z] = askMarginalLikelihood(0, Inf, thetaMLE', invFisher, sampSize, sampBurn);
    b = z(2:p+1)';
    s = z(1);
    ask(i) = lrLikelihood(y,X, b, s)  + logmvnpdf(b', empty', eye(p)) +...
        loginvgampdf(s, 3,6) - log(mean(prod(K,2)));
end
askStd = batchMeans(batches, ask);
askMean = mean(ask);
fprintf('ASK mean, std: %f, %f\n', askMean, askStd);



