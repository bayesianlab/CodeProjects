function [obsupdate, backup, f, otherOMupdate] = ...
    AmarginalF(Info, Factor, yt, currobsmod,  stateTransitions, factorVariance,...
    obsPrecision, backup,   otherOM, options)

[K,T] = size(yt);
Regions = size(Info,1);
f = zeros(Regions,T);
obsupdate = zeros(K,1);
otherOMupdate = zeros(K,1);

for r = 1:Regions
    subsetSelect = Info(r,1):Info(r,2);
    ySlice = yt(subsetSelect,:);

    precisionSlice = obsPrecision(subsetSelect);
    x0 = currobsmod(subsetSelect);
    x1 = otherOM(subsetSelect);
    factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
    lastMean = backup{r,1};
    lastCovar = backup{r,2};
    [xt, lastMean, lastCovar, xt1] = identification2(x0, ySlice,precisionSlice,...
        Factor(r,:), factorPrecision, lastMean,...
        lastCovar, x1, options);

    obsupdate(subsetSelect) = xt;
    otherOMupdate(subsetSelect) = xt1;
    backup{r,1} = lastMean;
    backup{r,2} = lastCovar;
    
    f(r,:) =  kowUpdateLatent(ySlice(:), xt, factorPrecision, precisionSlice);

end

end