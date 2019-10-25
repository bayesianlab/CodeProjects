function [obsupdate, backup, f] = ...
    ExperimentalAmF(Info, BlockingInfo, Factor, yt, currobsmod,  stateTransitions, factorVariance,...
    obsPrecision, backup,  options, identification, restrictionVec)

%%%%%%%%%%%%%%%Experimental%%%%%%%%%%%
[K,T] = size(yt);
Regions = size(Info,1);
Blocks = CountSubBlocks(Info, BlockingInfo);
f = zeros(Regions,T);
obsupdate = zeros(K,1);
fpCell = cell(1,Regions);
bcount = 0;
for r = 1:Regions
    factorPrecision = kowStatePrecision(stateTransitions(r), 1./factorVariance(r), T);
    fpCell{r} = factorPrecision;
    for b = 1:Blocks(r)
        bcount = bcount + 1;
        subsetSelect = BlockingInfo(bcount,1):BlockingInfo(bcount,2);
        rVecSub = restrictionVec(subsetSelect);
        isRestr = rVecSub(1);
        ySlice = yt(subsetSelect,:);
        precisionSlice = obsPrecision(subsetSelect);
        x0 = currobsmod(subsetSelect);
        lastMean = backup{bcount,1};
        lastCovar = backup{bcount,2};
        if isRestr == 0
            [xt, lastMean, lastCovar] = identification1(x0, ySlice,precisionSlice,...
                Factor(r,:), factorPrecision, lastMean,...
                lastCovar,  options);
            obsupdate(subsetSelect) = xt;

            backup{bcount,1} = lastMean;
            backup{bcount,2} = lastCovar;
        elseif isRestr == 1
            [xt, lastMean, lastCovar] = identification2(x0, ySlice,precisionSlice,...
                Factor(r,:), factorPrecision, lastMean,lastCovar,  options);
                       
            obsupdate(subsetSelect) = xt;
            backup{bcount,1} = lastMean;
            backup{bcount,2} = lastCovar;
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