function [currobsmod, Ft,  alpha, accept] = ...
    LoadingsFactorsUpdate(yt, Xbeta, Ft, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell,  a0, A0inv, tau)

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

accept = zeros(nFactors,1);
for q = 1:levels
    fprintf('\tLevel %i\n', q)
    COM = makeStateObsModel(currobsmod, Identities, q);
    mut =  xb + COM*Ft;
    ydemut = yt - mut;
    Info = InfoCell{1,q};
    region = size(Info,1);
    for r=1:region
        w1 = sqrt(chi2rnd(df,1)/df);
        fcount = fcount+1;
        gammas = stateTransitions(fcount,:);
        [L0,~,~,w] = initCovar(gammas, factorVariance(fcount));
        if w~=0
            L0 = eye(length(gammas));
        end
        StatePrecision = FactorPrecision(gammas, L0, 1./factorVariance(fcount), T);
        tempf = Ft(fcount,:);
        subset = Info(r,1):Info(r,2);
        s2 = (Info(r,1)+1):Info(r,2);
        ns2 = length(s2);
        
        ty = ydemut(s2,:);
        top = obsPrecision(s2);
        x0 = currobsmod(s2,q);
        a0m = a0.*ones(1,ns2);
        A0invp = A0inv.*eye(ns2);
        LL = @(guess) -LLcond_ratio(guess, ty, a0m, A0invp, top, tempf,StatePrecision);
        if length(s2) < 20
            [themean, ~,~,~,~, Covar] = fminunc(LL, x0, options);
            H = Covar\eye(length(s2));
        else
            [themean, Covar] = bfgs(x0, A0invp, LL, MaxIterations);
            H = Covar;
        end
        
        
        [Hlower, p] = chol(H,'lower');
        if p ~= 0
            Hlower = eye(length(s2));
            H = eye(length(s2));
        end

        proposal = themean + Hlower*normrnd(0,1,length(s2), 1)./w1;
        proposalDist= @(prop) mvstudenttpdf(prop, themean', tau(fcount).*H, df);

        Num = -LL(proposal) + proposalDist(x0');
        Den = -LL(x0) + proposalDist(proposal');
        alpha(fcount) = min(0,Num - Den);
        u = log(unifrnd(0,1,1,1));
        if u <= alpha(fcount)
            accept(fcount) = 1;
            currobsmod(subset,q) = [1;proposal];
        end
        %% Update Factor
        ty = ydemut(subset,:);
        top = obsPrecision(subset);
        Ft(fcount,:) =  kowUpdateLatent(ty(:), currobsmod(subset,q), StatePrecision, top);
    end
end

end