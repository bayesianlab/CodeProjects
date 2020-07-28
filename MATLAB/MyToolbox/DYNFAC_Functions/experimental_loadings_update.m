function [currobsmod, accept] = experimental_loadings_update(yt, Xbeta, Ft, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell,  a0, A0inv, tau, FtIndexMat)


MaxIterations = 50;
options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-8, 'Display', 'off', 'OptimalityTolerance', 1e-8, 'MaxIterations', MaxIterations);
df = 8;
[K,T] = size(yt);
fcount = 0;
levels = length(InfoCell);
nFactors = sum(cellfun(@(x)size(x,1), InfoCell));
alpha = zeros(nFactors,1);
xb = reshape(Xbeta, K,T);
lags = size(stateTransitions,2);
accept = zeros(K,1);
for k = 2:K
    w1 = sqrt(chi2rnd(df,1)/df);
    fdx = FtIndexMat(k,:);
    nz = find(fdx);
    fdx = fdx(nz);
    nF = length(fdx);
    st= stateTransitions(fdx,:);
    fv = factorVariance(fdx);
    [P0, ~,~, nv] = initCovar(st, fv);
    if nv == 1
        P0 = eye(nF*lags);
    end
    StatePrecision = FactorPrecision(st, P0, 1./fv, T);
    ty = yt(k,:);
    tf = Ft(fdx,:);
    op = obsPrecision(k);
    a0m = a0.*ones(1,nF);
    A0P = A0inv.*eye(nF);
    LL = @(guess) -LL_Ratio(guess, ty, a0m, A0P, op, tf, StatePrecision);
    
    x0 = currobsmod(k, 1:nF);
    [themean, ~,~,~,~, Covar] = fminunc(LL, x0, options);
    H = Covar\eye(length(themean));
    [Hlower, p] = chol(H,'lower');
    if p ~= 0
        H = eye(length(themean));
        Hlower= H;
    end
    
    proposal = themean' + Hlower*normrnd(0,1,length(themean), 1)./w1;
    proposalDist= @(prop) mvstudenttpdf(prop, themean, tau(k).*H, df);
    
    Num = -LL(proposal') + proposalDist(x0);
    Den = -LL(x0) + proposalDist(proposal');
    alpha(k) = min(0,Num - Den);
    u = log(unifrnd(0,1,1,1));
    if u <= alpha(k)
        accept(k) = 1;
        currobsmod(k,:) = proposal;
    end
end

end

