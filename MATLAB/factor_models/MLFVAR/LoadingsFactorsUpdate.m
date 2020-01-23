function [currobsmod, Ft, keepOmMeans, keepOmVariances, alpha] = ...
    LoadingsFactorsUpdate(yt, Xbeta, Ft, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell, keepOmMeans, keepOmVariances,...
    runningAverageMean, runningAverageVar)

options = optimoptions(@fminunc,'FiniteDifferenceType', 'central',...
    'StepTolerance', 1e-14, 'Display', 'off', 'OptimalityTolerance', 1e-14);
df = 20;
[K,T] = size(yt);
w1 = sqrt(chi2rnd(df,1)/df);
fcount = 0;
levels = length(InfoCell);
nFactors = sum(cellfun(@(x)size(x,1), InfoCell));
alpha = zeros(nFactors,1);

for q = 1:levels
    COM = makeStateObsModel(currobsmod, Identities, q);
    mut = Xbeta + COM*Ft;
    ydemut = yt - mut;
    Info = InfoCell{1,q};
    region = size(Info,1);
    for r=1:region
        fcount = fcount+1;
        gammas = stateTransitions(fcount,:);
        [L0, ssgam] = initCovar(diag(gammas));
        StatePrecision = FactorPrecision(ssgam, L0, 1./factorVariance(fcount), T);
        tempf = Ft(fcount,:);
        subset = Info(r,1):Info(r,2);
        a0 = zeros(1, length(subset)-1);
        A0=eye(length(subset)-1);
        %% Optimization step
        for k =subset
            ty = ydemut(k,:);
            top = obsPrecision(k);
            x0 = currobsmod(k,q);
            LL = @(guess) -LLcond_ratio(guess, ty, 1, 1, top, tempf,StatePrecision);
            [themean, ~,~,~,~, Hessian] = fminunc(LL, x0, options);

            if Hessian < 0 
                Hessian = 1;
            end
            keepOmVariances(k,q)= 1/Hessian;
            keepOmMeans(k,q)=themean;
        end
        
        %% MH step
        ty = ydemut(subset,:);
        ty = ty(2:end,:);
        top = obsPrecision(subset);
        top = top(2:end);
        omMuNum = keepOmMeans(subset,q);
        omVarNum = keepOmVariances(subset,q);
        omMuDen = runningAverageMean(subset,q);
        omVarDen = runningAverageVar(subset,q);
        omMuNum = omMuNum(2:end);
        omVarNum = omVarNum(2:end);
        omMuDen = omMuDen(2:end);
        omVarDen = omVarDen(2:end);
        proposal = omMuNum + diag(sqrt(omVarNum))*normrnd(0,1,length(subset)-1, 1)./w1;
        proposalDistNum = @(prop) mvstudenttpdf(prop, omMuNum', diag(omVarNum), df);
        proposalDistDen = @(prop) mvstudenttpdf(prop, omMuDen', diag(omVarDen), df);
        LogLikePositive = @(val) LLcond_ratio (val, ty, a0,A0, top, tempf, StatePrecision);
        x0 = currobsmod(subset,q);
        Num = LogLikePositive(proposal) + proposalDistNum(x0(2:end)');
        Den = LogLikePositive(x0(2:end)) + proposalDistDen(proposal');
        alpha(fcount) = min(0,Num - Den);
        u = log(unifrnd(0,1,1,1));
        if u <= alpha(fcount)
            currobsmod(subset,q) = [1;proposal];
        end
        %% Update Factor
        ty = ydemut(subset,:);
        top = obsPrecision(subset);  
        Ft(fcount,:) =  kowUpdateLatent(ty(:), currobsmod(subset,q), StatePrecision, top);
    end
end
end