function [ml] = imp(a,b,mu,Sigma,y, X, N, burnin, b0,B0,a0,d0)
[J,~] = size(Sigma);
Hxx = diag(inv(Sigma));
sigmaii = sqrt( (Hxx).^(-1) );
ghkSample = tmultnormrndEta(a,b,mu,Sigma,N);
beta = ghkSample(burnin:N,2:J);
sigmasqd = ghkSample(burnin:N,1);
like = lrLikelihood(y,X,beta',sigmasqd);
lmvn = logmvnpdf(beta', mu(2:J), 100*B0);
lig = loginvgampdf(sigmasqd, a0,d0)';
htheta = log(prod(tnormpdf(a,b,mu,sigmaii,ghkSample(burnin:N,:)'),1)');
ml = mean(like + lmvn + lig - htheta);
fprintf('Imp Log marginal likelihood %f\n', ml)
end

