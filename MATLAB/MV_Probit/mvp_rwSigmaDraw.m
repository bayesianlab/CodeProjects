function [CurrentSigma, accept] = mvp_rwSigmaDraw(CurrentSigma, zt, sig0, Sig0, unvech,...
    vechIndex, start, tau)
%% Help for mvp_rwSigmaDraw
% sig0 and Sig0 are priors for CurrentSigma
options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-8, 'Display', 'off', 'OptimalityTolerance', 1e-8, 'MaxIterations', 25);
[K,~]=size(CurrentSigma);
accept = zeros(K-1,1);
df = 15;

for k = start:K-1
    vindx = vechIndex(k,1) : vechIndex(k,2);
    nsubk = length(vindx);
    
    mu = zeros(1,K);
    s0 = ones(nsubk,1).*sig0;
    S0 = Sig0.*eye(nsubk);
    constelems = vech(CurrentSigma, -1);
    negLL = @(vs)  mvp_likelihood(vs, constelems, zt, mu, s0, S0, unvech, vindx);
    x0 = constelems(vindx);
    [candmu, ~, ~, ~, ~, H] = fminunc(negLL, x0, options);
    [Hlower, p] =chol(H,'lower');
    test2 = (nsubk^2 == sum(sum(isfinite(Hlower))));
    if p ~= 0 || test2 == 0
        Covar = eye(nsubk);
    else
        Covar = Hlower\eye(nsubk);
    end
    w = chi2rnd(df) ;
    candidate = candmu + Covar'*normrnd(0,1,nsubk,1)/sqrt(w);
    constelems(vindx) = candidate;
    candidate1 = constelems;
    Q = unvech*candidate1;
    Q =reshape(Q,K,K);
    Cand = Q + Q' + eye(K);
    [~, pp] = chol(Cand);
    if pp == 0
        ProposalCovar = Covar'*Covar;
        [~, p] = chol(ProposalCovar,'lower');
        if p ~= 0
            ProposalCovar = eye(nsubk);
        end
        
        LL = @(P)  sum(logmvnpdf(zt', mu, P)) ;
        Prior = @(P)  logmvnpdf(P, s0', S0);
        Prop = @(P) mvstudenttpdf(P, candmu', tau(k).*ProposalCovar, df);
        Num = LL(Cand) + Prior(candidate') + Prop(x0');
        Den = LL(CurrentSigma) + Prior(x0') + Prop(candidate');
        alpha = min( 0, Num - Den );
        lu = log(unifrnd(0,1));
        if lu < alpha
            accept(k) = 1;
            CurrentSigma = Cand;
        end
    end
    
end
end
