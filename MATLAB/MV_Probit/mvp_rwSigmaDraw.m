function [CurrentSigma] = mvp_rwSigmaDraw(CurrentSigma, zt, tau0, T0, sig0, Sig0, unvech,...
    vechIndex)
options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-8, 'Display', 'off', 'OptimalityTolerance', 1e-8, 'MaxIterations', 25);
[K,~]=size(CurrentSigma);

for k = 1:K-1
    vindx = vechIndex(k,1) : vechIndex(k,2);
    nsubk = length(vindx);
    mu = zeros(1,K);
    s0 = sig0(vindx);
    S0 = Sig0.*eye(nsubk);
    constelems = vech(CurrentSigma, -1);
    
    negLL = @(vs)  mvp_likelihood(vs, constelems, zt, mu, s0, S0, unvech, vindx);
    x0 = constelems(vindx);
    [candmu, ~, ~, ~, ~, H] = fminunc(negLL, x0, options);
    [Hlower, p] =chol(H,'lower');
    if p ~= 0
        Covar = eye(nsubk);
    else
        
        Covar = Hlower\eye(nsubk);
    end
    df = 15;
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
        LL = @(P)  sum(logmvnpdf(zt', mu, P)) ;
        Prior = @(P)  logmvnpdf(P, s0', S0);
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
end
