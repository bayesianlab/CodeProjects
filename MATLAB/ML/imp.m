function [ml] = imp(a,b,mu,Sigma,y, X, N,b0,B0,a0,d0)
[J,~] = size(Sigma);
ghkSample = tmultnormrndEta(a,b,mu,Sigma,N);
beta = ghkSample(:,2:J);
sigmasqd = ghkSample(:,1);
like = lrLikelihood(y,X,beta',sigmasqd);

lmvn = logmvnpdf(beta', mu(2:J), 100*B0)
lig = loginvgampdf(sigmasqd, a0,d0)'

ml = mean(like + lmvn + lig - htheta);

end

