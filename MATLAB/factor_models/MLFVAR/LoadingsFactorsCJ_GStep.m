function [alpha_prop] = ...
    LoadingsFactorsCJ_GStep(fixedValueTheta, thetaG, yt, Xbeta, Ft, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell,runningAvgMu, runningAvgVar)

df = 15;
[K,T] = size(yt);
fcount = 0;
levels = length(InfoCell);
nFactors = sum(cellfun(@(x)size(x,1), InfoCell));
alpha_prop = zeros(nFactors,1);
for q = 1:levels
    COM = makeStateObsModel(thetaG, Identities, q);
    mut = Xbeta + COM*Ft;
    ydemut = yt - mut;
    Info = InfoCell{1,q};
    regs = size(Info,1);
    for r=1:regs
        fcount = fcount+1;
        gammas = stateTransitions(fcount,:);
        [L0, ssgam] = initCovar(diag(gammas));
        StatePrecision = FactorPrecision(ssgam, L0, 1./factorVariance(fcount), T);
        tempf = Ft(fcount,:);
        subset = Info(r,1):Info(r,2);
        %% MH step
        ty = ydemut(subset,:);
        ty = ty(2:end,:);
        top = obsPrecision(subset);
        top = top(2:end);
        omMuNum = runningAvgMu(subset,q);
        omVarNum = runningAvgVar(subset,q);
        omMuNum = omMuNum(2:end);
        omVarNum=omVarNum(2:end);
        fxTheta = fixedValueTheta(subset,q);
        gTheta = thetaG(subset, q);
        proposalDistNum = @(prop) mvstudenttpdf(prop, omMuNum', diag(omVarNum), df);
        LogLikePositive = @(val) LLcond_ratio (val, ty, .25.*ones(1, length(subset)-1),...
            eye(length(subset)-1), top, tempf, StatePrecision);
        Num = LogLikePositive(fxTheta(2:end)) + proposalDistNum(gTheta(2:end)');
        Den = LogLikePositive(gTheta(2:end)) + proposalDistNum(fxTheta(2:end)');
        alpha_prop(fcount) = min(0,Num - Den) +  proposalDistNum(fxTheta(2:end)');
    end
end
end



