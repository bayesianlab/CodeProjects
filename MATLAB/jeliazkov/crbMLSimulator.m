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
a= 0;
b = Inf;
L = chol(invFisher, 'lower');
[J,~] = size(invFisher);
[alpha, beta] = standardizedConstraints(a,b, L, thetaMLE', J);
notj = notJindxs(J);

H = inv(invFisher);
precisionDiag = diag(H);
burnin = 5;
sSize = 20;
sample = zeros(sSize,3,J);
thetaMLE'
for i = 1:Sims
crbML(a,b,thetaMLE',invFisher,sSize,burnin)
%     b = z(2:p+1)';
%     s = z(1);
%     crb(i) = lrLikelihood(y,X, b, s)  + logmvnpdf(b', empty', eye(p)) + ...
%         loginvgampdf(s, 3,6) - log(prod(fz,2));
%     sample = zeros(sSize,3,J);
end
% crbStd = batchMeans(batches, crb);
% crbMean= mean(crb);
% fprintf('CRB mean, std: %f, %f\n', crbMean, crbStd);


