function [] = mhWorld(mu, Hessian)
% First element positve
df = 15;
w1 = sqrt(chi2rnd(df,1)/df);
w2 = sqrt(chi2rnd(df+1,1)/(df+1));

Precision = Hessian\eye(size(Hessian,1));

sigma = sqrt(Hessian(1,1));
restricteddraw = truncNormalRand(0, Inf, mu(1), sigma)/w1;
log(ttpdf(0,Inf,mu(1), sigma,15, restricteddraw))

demurestrict = restricteddraw - mu(1);
condmean = mu(2:end) - Precision(2:end, 2:end)\Precision(2:end, 1) *( demurestrict);
condvar = ((df + demurestrict^2*(1/Precision(1,1)))/ (df +1)) / Precision;
condmean
condvar
end

