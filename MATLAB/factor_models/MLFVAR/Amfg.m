function [alphag] = Amfg(Info, BlockingInfo, Factor, yt,  xstar, xg,...
    stateTransitions, factorVariance,obsPrecision, backup, restrictionVec)

[K,T] = size(yt);
Regions = size(Info,1);
Blocks = CountSubBlocks(Info, BlockingInfo);
f = zeros(Regions,T);
obsupdate = zeros(K,1);
fpCell = cell(1,Regions);
bcount = 0;
df = 15;
w1 = sqrt(chi2rnd(df,1)/df);
alphag = zeros(Regions,1);
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
        omStar = xstar(subsetSelect);
        if isRestr == 0
            ObsPriorMean = ones(1, littlek);
            ObsPriorPrecision = eye(littlek);
            LogLikePositive = @(v) LLcond_ratio (v, ySlice, ObsPriorMean,...
                ObsPriorPrecision, precisionSlice, Factor(r,:), factorPrecision);
            proposalDist = @(q) mvstudenttpdf(q, meanA, Covariance, df);
            freeElems = xg(subsetSelect);
            Num = LogLikePositive(omStar) + proposalDist(freeElems');
            Den = LogLikePositive(freeElems) + proposalDist(omStar');
            alphag(bcount)  = min(0,Num - Den) + proposalDist(omStar');

        elseif isRestr == 1
            ObsPriorMean = ones(1, littlek-1);
            ObsPriorPrecision = eye(littlek-1);
            omStar = xstar(subsetSelect);
            LogLikePositive = @(v) LLRestrict (v, ySlice, ObsPriorMean,...
                ObsPriorPrecision, precisionSlice, Factor(r,:), factorPrecision);
            proposalDist = @(q) mvstudenttpdf(q, meanA, Covariance, df);
            freeElems = xg(subsetSelect);
            freeElems = freeElems(2:end);
            Num = LogLikePositive(omStar(2:end)) + proposalDist(freeElems');
            Den = LogLikePositive(freeElems) + proposalDist(omStar(2:end)');
            alphag(bcount)  = min(0,Num - Den) + proposalDist(omStar(2:end)');
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

