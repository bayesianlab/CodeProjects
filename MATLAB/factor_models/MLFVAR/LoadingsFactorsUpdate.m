function [currobsmod, Ft, keepOmMeans, keepOmVariances, alpha] = ...
    LoadingsFactorsUpdate(yt, Xbeta, Ft, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell, keepOmMeans, keepOmVariances,...
    runningAverageMean, runningAverageVar)

options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-8, 'Display', 'off', 'OptimalityTolerance', 1e-8);
df = 15;
[K,T] = size(yt);
w1 = sqrt(chi2rnd(df,1)/df);
fcount = 0;
levels = length(InfoCell);
nFactors = sum(cellfun(@(x)size(x,1), InfoCell));
alpha = zeros(nFactors,1);
for q = 1:levels
    ycount = 0;
    COM = makeStateObsModel(currobsmod, Identities, q);
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
        %% Optimization step
        for k =subset
            ycount = ycount + 1;
            ty = ydemut(ycount,:);
            top = obsPrecision(ycount);
            x0 = currobsmod(k,q);
            LL = @(guess) -LLcond_ratio(guess, ty,.5, 1, top, tempf,StatePrecision);
            [themean, ~,~,~,~, Hessian] = fminunc(LL, x0, options);
            keepOmVariances(k,q)= 1/Hessian;
            keepOmMeans(k,q)=themean;
        end
        %% MH step
        ty = ydemut(subset,:);
        top = obsPrecision(subset);
        omMuNum = keepOmMeans(subset,q);
        omStdNum = sqrt(keepOmVariances(subset,q));
        omMuDen = runningAverageMean(subset,q);
        proposal = omMuNum + diag(omStdNum)*normrnd(0,1,length(subset), 1)./w1;
        proposalDistNum = @(prop) mvstudenttpdf(prop, omMuNum', diag(keepOmVariances(subset,q)), df);
        proposalDistDen = @(prop) mvstudenttpdf(prop, omMuDen', diag(runningAverageVar(subset,q)), df);
        LogLikePositive = @(val) LLcond_ratio (val, ty, .5.*ones(1, length(subset)),...
            eye(length(subset)), top, tempf, StatePrecision);
        Num = LogLikePositive(proposal) + proposalDistNum(currobsmod(subset,q)');
        Den = LogLikePositive(currobsmod(subset,q)) + proposalDistDen(proposal');
        alpha(fcount) = min(0,Num - Den);
        u = log(unifrnd(0,1,1));
        if u <= alpha
            currobsmod(subset,q) = proposal;
        end
        currobsmod(subset(1),q) = 1;
        %% Update Factor
        Ft(r,:) =  kowUpdateLatent(ty(:), currobsmod(subset,q), StatePrecision, top);
    end
end
end



