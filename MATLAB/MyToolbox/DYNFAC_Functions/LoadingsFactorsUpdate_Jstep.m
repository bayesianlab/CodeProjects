function [Ft,  alpha] = ...
    LoadingsFactorsUpdate_Jstep(yt, Xbeta, Ft, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell,...
    storeMeans, storeVars, a0, A0inv)

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
        [L0,~,~,w] = initCovar(gammas, factorVariance(fcount));
        if w ~=0
            L0 = eye(length(gammas))
        end
        StatePrecision = FactorPrecision(gammas, L0, 1./factorVariance(fcount), T);
        tempf = Ft(fcount,:);
        subset = Info(r,1):Info(r,2);
        s2 = (Info(r,1)+1):Info(r,2);


        x0 = currobsmod(s2,q);
        a0m = a0.*ones(1,length(s2));
        A0invp = A0inv.*eye(length(s2));
        
        themean = storeMeans{fcount};
        H = storeVars{fcount};
        Hlower = chol(H,'lower');
        ty = ydemut(subset,:);
        ty = ty(2:end,:);
        top = obsPrecision(subset);
        top = top(2:end);
        
        proposalj = themean + Hlower*normrnd(0,1,length(s2), 1)./w1;
        proposalDist= @(prop) mvstudenttpdf(prop, themean', H, df);
        
        LogLikePositive = @(val) LLcond_ratio (val, ty, a0m,A0invp, top, tempf, StatePrecision);
        Num = LogLikePositive(proposalj) + proposalDist(x0');
        Den = LogLikePositive(x0) + proposalDist(proposalj');
        alpha(fcount) = min(0,Num - Den);
        u = log(unifrnd(0,1,1,1));
        if u <= alpha(fcount)
            currobsmod(subset,q) = [1;proposalj];
        end
        %% Update Factor
        ty = ydemut(subset,:);
        top = obsPrecision(subset);
        Ft(fcount,:) =  kowUpdateLatent(ty(:), currobsmod(subset,q), StatePrecision, top);
    end
end

end