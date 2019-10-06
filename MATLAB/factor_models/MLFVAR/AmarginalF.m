function [obsupdate, backup, f] = ...
    AmarginalF(Info, Factor, yt, currobsmod,  stateTransitions, factorVariance,...
    obsPrecision, backup,  options, identification)

[K,T] = size(yt);
Regions = size(Info,1);
f = zeros(Regions,T);
obsupdate = zeros(K,1);

for r = 1:Regions
    subsetSelect = Info(r,1):Info(r,2);
    ySlice = yt(subsetSelect,:);
    precisionSlice = obsPrecision(subsetSelect);
    x0 = currobsmod(subsetSelect);
    factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
    lastMean = backup{r,1};
    lastCovar = backup{r,2};
    if identification == 1
        [xt, lastMean, lastCovar] = identification1(x0, ySlice,precisionSlice,...
            Factor(r,:), factorPrecision, lastMean,...
            lastCovar,  options);
        obsupdate(subsetSelect) = xt;
        backup{r,1} = lastMean;
        backup{r,2} = lastCovar;
    elseif identification == 2
        [xt, lastMean, lastCovar] = identification2(x0, ySlice,precisionSlice,...
            Factor(r,:), factorPrecision, lastMean,...
            lastCovar,  options);
        obsupdate(subsetSelect) = xt;
        backup{r,1} = lastMean;
        backup{r,2} = lastCovar;
    end
    
    f(r,:) =  kowUpdateLatent(ySlice(:), xt, factorPrecision, precisionSlice);
    
end

end