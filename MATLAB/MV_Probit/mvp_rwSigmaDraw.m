function [CurrentSigma] = mvp_rwSigmaDraw(CurrentSigma, zt, tau0, T0, sig0, Sig0, unvech)
options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-8, 'Display', 'off', 'OptimalityTolerance', 1e-8, 'MaxIterations', 25);
[K,~]=size(CurrentSigma);
lambda=min(eig(CurrentSigma));
ZeroK = zeros(1,K);
mu = zeros(1,K);
% negLL = @(offterms) -( sum(logmvnpdf(zt', mu, CurrentSigma)) +  logmvnpdf(offterms, sig0', Sig0));
negLL = @(vs)  mvp_likelihood(vs, zt, mu, sig0, Sig0, unvech, K);
x0 = vech(CurrentSigma, -1);
[candmu, ~, ~, ~, ~, H] = fminunc(negLL, x0, options);
[Hlower, p] =chol(H,'lower');
if p ~= 0
    Covar = eye(length(x0));
else
    Covar = Hlower\eye(length(x0));
end
df = 15;
w = chi2rnd(df) ;

candidate = candmu + Covar'*normrnd(0,1,length(x0),1)/sqrt(w);
Q = unvech*candidate;
Q =reshape(Q,K,K);
Cand = Q + Q' + eye(K);
[~, pp] = chol(Cand);
if pp == 0
    ProposalCovar = Covar'*Covar;
    LL = @(P)  sum(logmvnpdf(zt', mu, P)) ;
    Prior = @(P)  logmvnpdf(P, sig0', Sig0);
    Prop = @(P) mvstudenttpdf(P, candmu', ProposalCovar, df);
    Num = LL(Cand) + Prior(candidate') + Prop(x0');
    Den = LL(CurrentSigma) + Prior(x0') + Prop(candidate');
    alpha = min( 0, Num - Den );
    lu = log(unifrnd(0,1));
    if lu < alpha
        CurrentSigma = Cand;
    end
end

end

