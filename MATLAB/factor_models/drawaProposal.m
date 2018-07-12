function [aProposal, proposalpdfastar, proposalpdf, LLastar, LLa, ahat, Ahat] =...
    drawaProposal(y,mu, Sigma, Sinv, a, df, yeqns, T)
w1 = sqrt(chi2rnd(df,1)/df);
w2 = sqrt(chi2rnd(df+1,1)/(df+1));
gradLL = @(guess)dLogLikeFactorModel(guess, y, mu, Sigma, Sinv);
[ahat, Ahat] = bhhh(a, gradLL, 10, 1e-5, .2);
Tscale = chol(Ahat,'lower');
aPrecision = inv(Ahat);
cmu = ahat(1) - (1/aPrecision(1,1))*aPrecision(1,2:end)*...
    (a(2:end) - ahat(2:end));
cvar = 1/aPrecision(1,1);
restrictedProposal = truncNormalRand(0,Inf, cmu, cvar)/w2;
unrestrictedProposal = (ahat(2) + Tscale(2:end,2:end)*normrnd(0,1,1))/w1;
aProposal = [restrictedProposal, unrestrictedProposal]';
yt = reshape(y, [yeqns,T]);
mut = reshape(mu,[yeqns,T]);
proposalpdfastar = mhtpdf(0,Inf, restrictedProposal, cmu, cvar, df+1,...
    unrestrictedProposal, ahat(2:end), Ahat(2:end,2:end), df);
proposalpdf = mhtpdf(0,Inf, a(1), cmu, cvar, df+1, a(2:end), ahat(2),...
        Ahat(2:end,2:end), df);
LLastar = factorModelLogLikelihood(yt, mut, Sigma, aProposal,Sinv);
LLa = factorModelLogLikelihood(yt, mut, Sigma, a,Sinv);
end

