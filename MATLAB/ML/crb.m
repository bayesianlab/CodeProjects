function [ml] = crb(a,b,mu, Sigma, y,X, N,...
    burnin, rrN, rrBurnin, init, b0,B0,a0,d0)
[J, ~] = size(Sigma);
sample = tmultnormrnd(a,b,mu,Sigma,N,init);
sample = sample(burnin:N,:);
[z, fz] = chibml(a,b,mu,Sigma,sample,rrN, rrBurnin);
like = lrLikelihood(y,X, z(2:J), z(1));
lmvn = logmvnpdf(z(2:J), mu(2:J), 100*B0);
lig = loginvgampdf(z(1), a0,d0);
lpfz = log(prod(fz));
ml = like + lmvn + lig - lpfz;
fprintf('Log marginal likelihood %f\n', ml)
end

