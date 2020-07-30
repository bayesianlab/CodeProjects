function [currobsmod, Ft, alpha, d] = ...
    mvp_LoadFac_Jstep(yt, Xbeta, Ft, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell,  a0, A0,storeMeans, storeVars)


df = 20;
[K,T] = size(yt);
w1 = sqrt(chi2rnd(df,1)/df);
fcount = 0;
levels = length(InfoCell);
nFactors = sum(cellfun(@(x)size(x,1), InfoCell));
alpha = zeros(nFactors,1);
xb = reshape(Xbeta, K,T);
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
        lsub = length(subset);
        
        
        x0 = currobsmod(subset,q);
        a0m = a0.*ones(1,length(subset));
        A0invp = (1/A0).*eye(length(subset));
        
        themean = storeMeans{fcount};
        H = storeVars{fcount};
        Hlower = chol(H,'lower');
        ty = ydemut(subset,:);
        top = obsPrecision(subset);
    
  
        proposal = themean + Hlower*normrnd(0,1,length(subset), 1)./w1;
        if proposal(1) <0
            proposal(1) = abs(proposal(1));
        end
        C = diag(proposal*proposal' + eye(lsub));
        D = diag(C.^(-.5));
        d= diag(D);
        proposal= D*proposal;
        
        proposalDist= @(prop) mvstudenttpdf(prop, themean', H, df);
        LogLikePositive = @(val) LLcond_ratio (val, ty, a0m,A0invp, top, tempf, StatePrecision);
        Num = LogLikePositive(proposal) + proposalDist(x0');
        Den = LogLikePositive(x0) + proposalDist(proposal');
        alpha(fcount) = min(0,Num - Den);
        u = log(unifrnd(0,1,1,1));
        if u <= alpha(fcount)
            currobsmod(subset,q) = proposal;
        end
        
        %% Update Factor

        Ft(fcount,:) =  kowUpdateLatent(ty(:), currobsmod(subset,q), StatePrecision, 1./d);
    end
end

end