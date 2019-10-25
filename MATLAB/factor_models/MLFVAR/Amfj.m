function [obsupdate, backup, f, alphaj] = ...
    Amfj(Info, BlockingInfo, Factor, yt, currobsmod,  stateTransitions, factorVariance,...
    obsPrecision, backup,restrictionVec)

[K,T] = size(yt);
Regions = size(Info,1);
Blocks = CountSubBlocks(Info, BlockingInfo);
f = zeros(Regions,T);
obsupdate = zeros(K,1);
fpCell = cell(1,Regions);
bcount = 0;
alphaj = zeros(Regions,1);
df = 15;
w1 = sqrt(chi2rnd(df,1)/df);

for r = 1:Regions
    factorPrecision = kowStatePrecision(stateTransitions(r), 1./factorVariance(r), T);
    fpCell{r} = factorPrecision;
    for b = 1:Blocks(r)
        bcount = bcount + 1;
        subsetSelect = BlockingInfo(bcount,1):BlockingInfo(bcount,2);
        rVecSub = restrictionVec(subsetSelect);
        isRestr = rVecSub(1);
        littlek = length(subsetSelect);
        meanA = backup{bcount,1};
        Covariance = backup{bcount,2};
        ySlice = yt(subsetSelect,:);
        precisionSlice = obsPrecision(subsetSelect);        
        if isRestr == 0
            ObsPriorMean = ones(1, littlek);
            ObsPriorPrecision = eye(littlek);
            xj = meanA' + chol(Covariance, 'lower')*normrnd(0,1, littlek,1)./w1;
            xstar = currobsmod(subsetSelect);     
            obsupdate(subsetSelect) = xj;
            LogLikePositive = @(v) LLcond_ratio (v, ySlice, ObsPriorMean,...
                ObsPriorPrecision, precisionSlice, Factor(r,:), factorPrecision);
            proposalDist = @(q) mvstudenttpdf(q, meanA, Covariance, df);
            Num = LogLikePositive(xj) + proposalDist(xstar');
            Den = LogLikePositive(xstar) + proposalDist(xj');
            alphaj(bcount)  = min(0,Num - Den) ;
            if  log(unifrnd(0,1)) < alphaj(bcount)
                obsupdate(subsetSelect) = xj;
            else
                obsupdate(subsetSelect) = xstar;
            end
        elseif isRestr == 1
            ObsPriorMean = ones(1, littlek-1);
            ObsPriorPrecision = eye(littlek-1);
            xj = meanA' + chol(Covariance, 'lower')*normrnd(0,1, littlek-1,1)./w1;
            xstar = currobsmod(subsetSelect);
            LogLikePositive = @(v) LLRestrict (v, ySlice, ObsPriorMean,...
                ObsPriorPrecision, precisionSlice, Factor(r,:), factorPrecision);
            proposalDist = @(q) mvstudenttpdf(q, meanA, Covariance, df);
            Num = LogLikePositive(xj) + proposalDist(xstar(2:end)');
            Den = LogLikePositive(xstar(2:end)) + proposalDist(xj');
            alphaj(bcount)  = min(0,Num - Den) ;
            if  log(unifrnd(0,1)) < alphaj(bcount)
                obsupdate(subsetSelect) = [1;xj];
            else
                obsupdate(subsetSelect) = xstar;
            end
        end
    end
end
for r = 1:Regions
    subsetSelect = Info(r,1):Info(r,2);
    ySlice = yt(subsetSelect,:);
    precisionSlice = obsPrecision(subsetSelect);
    xt = obsupdate(subsetSelect);
    f(r,:) =  kowUpdateLatent(ySlice(:), xt, fpCell{r}, precisionSlice);
end
end

