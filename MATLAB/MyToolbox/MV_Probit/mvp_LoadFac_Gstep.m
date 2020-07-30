function [alpha_prop] = ...
    mvp_LoadFac_Gstep(fixedValueTheta, thetaG, yt, Xbeta, Ft, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell,a0, A0,storeMeans, storeVars)

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
        [L0, ssgam] = initCovar(stateTransitions(fcount,:), factorVariance(fcount));
        StatePrecision = FactorPrecision(ssgam, L0, 1./factorVariance(fcount), T);
        tempf = Ft(fcount,:);
        subset = Info(r,1):Info(r,2);
        apriormean = a0.*ones(1, length(subset));
        Apriorprecision =  (1/A0).*eye(length(subset));
        %% MH step
        ty = ydemut(subset,:);
        top = obsPrecision(subset);
        omMuNum = storeMeans{fcount};
        omVarNum = storeVars{fcount};
        
        fxTheta = fixedValueTheta(subset,q);
        gTheta = thetaG(subset, q);
        
        C = diag(gTheta*gTheta' + eye(length(subset)));
        D = diag(C.^(-.5));
        d= diag(D);
        gTheta= D*gTheta;
        
        
        proposalDistNum = @(prop) mvstudenttpdf(prop, omMuNum', omVarNum, df);
        LogLikePositive = @(val) LLcond_ratio (val, ty, apriormean, Apriorprecision, top, tempf, StatePrecision);
        Num = LogLikePositive(fxTheta) + proposalDistNum(gTheta');
        Den = LogLikePositive(gTheta) + proposalDistNum(fxTheta');
        alpha_prop(fcount) = min(0,Num - Den) +  proposalDistNum(fxTheta');
        
        
    end
    
end
end



