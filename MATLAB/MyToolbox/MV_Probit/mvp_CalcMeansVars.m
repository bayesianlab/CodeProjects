function [storeMeans, storeVars] = mvp_CalcMeansVars(SigmaStar,zt, sig0, Sig0, unvech,...
    vechIndex)

options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-8, 'Display', 'off', 'OptimalityTolerance', 1e-8, 'MaxIterations', 25);
K=size(zt,1);
storeMeans = cell(K-1);
storeVars = cell(K-1);
for k = 1:K-1
    vindx = vechIndex(k,1) : vechIndex(k,2);
    nsubk = length(vindx);
    mu = zeros(1,K);
    s0 = sig0(vindx);
    S0 = Sig0.*eye(nsubk);
    constelems = vech(SigmaStar, -1);
    
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
        [~, p] = chol(ProposalCovar,'lower');
        if p ~= 0
            ProposalCovar = eye(nsubk);
        end
        storeMeans{k} = candmu;
        storeVars{k} = ProposalCovar;
    end
    
end
end

