function [alpha_prop] = ...
    LoadingsFactorsCJ_GStep(fixedValueTheta, thetaG, yt, Xbeta, Ft, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell, keepOmMeans, keepOmVariances,...
    runningAvgMu, runningAvgVar)

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
        gammas = stateTransitions(r,:);
        [L0, ssgam] = initCovar(diag(gammas));
        StatePrecision = FactorPrecision(ssgam, L0, 1./factorVariance(r), T);
        tempf = Ft(fcount,:);
        subset = Info(r,1):Info(r,2);
        %% MH step
        ty = ydemut(subset,:);
        top = obsPrecision(subset);
        omMuNum = keepOmMeans(subset,q);
        omMuDen = runningAvgMu(subset,q);
        fxTheta = fixedValueTheta(subset,q);
        gTheta = thetaG(subset, q);
        proposalDistNum = @(prop) mvstudenttpdf(prop, omMuNum', diag(keepOmVariances(subset,q)), df);
        proposalDistDen = @(prop) mvstudenttpdf(prop, omMuDen', diag(runningAvgVar(subset,q)), df);
        LogLikePositive = @(val) LLcond_ratio (val, ty, .5.*ones(1, length(subset)),...
            eye(length(subset)), top, tempf, StatePrecision);
        Num = LogLikePositive(fxTheta) + proposalDistNum(gTheta');
        Den = LogLikePositive(gTheta) + proposalDistDen(fxTheta');
        alpha_prop(fcount) = min(0,Num - Den) +  proposalDistDen(fxTheta');
    end
end
end



