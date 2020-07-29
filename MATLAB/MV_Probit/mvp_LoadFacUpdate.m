function [currobsmod, Ft, alpha,  accept] = ...
    mvp_LoadFacUpdate(yt, Xbeta, Ft, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell,  a0, A0)

options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-8, 'Display', 'off', 'OptimalityTolerance', 1e-8, 'MaxIterations', 25);
df = 20;
[K,T] = size(yt);
w1 = sqrt(chi2rnd(df,1)/df);
fcount = 0;
levels = length(InfoCell);
nFactors = sum(cellfun(@(x)size(x,1), InfoCell));
alpha = zeros(nFactors,1);
xb = reshape(Xbeta, K,T);
accept = zeros(nFactors,1);
for q = 1:levels
    COM = makeStateObsModel(currobsmod, Identities, q);
    mut =  xb + COM*Ft;
    ydemut = yt - mut;
    Info = InfoCell{1,q};
    region = size(Info,1);
    for r=1:region
        fcount = fcount+1;
        gammas = stateTransitions(fcount,:);
        L0 = initCovar(gammas, factorVariance(fcount));
        StatePrecision = FactorPrecision(gammas, L0, 1./factorVariance(fcount), T);
        tempf = Ft(fcount,:);
        subset = Info(r,1):Info(r,2);
        s2 = (Info(r,1)+1):Info(r,2);
        ns2 = length(s2);
        ty = ydemut(s2,:);
        top = obsPrecision(s2);
        x0 = currobsmod(s2,q);
        a0m = a0.*ones(1,length(s2));
        A0invp = (1/A0).*eye(length(s2));
        LL = @(guess) -LLcond_ratio(guess, ty, a0m, A0invp, top, tempf,StatePrecision);
        [themean, ~,~,~,~, Covar] = fminunc(LL, x0, options);
        H = Covar\eye(length(s2));
        [Hlower, p] = chol(H,'lower');
        if p ~= 0 
            Hlower = eye(length(s2));
            H = eye(length(s2));
        end
        ty = ydemut(subset,:);
        ty = ty(2:end,:);
        top = obsPrecision(subset);
        top = top(2:end);
        
        proposal = themean + Hlower*normrnd(0,1, ns2, 1)./w1;
        C = diag([1;proposal]*[1;proposal]' + eye(ns2+1));        
        D = diag(C.^(-.5));
        d= diag(D);
        temp = D*[1;proposal];        
        proposal = temp(2:end);
                
        proposalDist= @(prop) mvstudenttpdf(prop, themean', H, df);
        LogLikePositive = @(val) LLcond_ratio (val, ty, a0m,A0invp, top, tempf, StatePrecision);
        Num = LogLikePositive(proposal) + proposalDist(x0');
        Den = LogLikePositive(x0) + proposalDist(proposal');
        alpha(fcount) = min(0,Num - Den);
        u = log(unifrnd(0,1,1,1));
        if u <= alpha(fcount)
            accept(fcount) =  1;
            currobsmod(subset,q) = [temp(1);proposal];
        end
        
        %% Update Factor
        ty = ydemut(subset,:);
        
        top = diag(D*eye(ns2+1));
        
        Ft(fcount,:) =  kowUpdateLatent(ty(:), currobsmod(subset,q), StatePrecision, top);
    end
end

end