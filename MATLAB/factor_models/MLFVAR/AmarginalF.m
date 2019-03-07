function [obsupdate, backup, f] = ...
    AmarginalF(Info, Factor, yt, currobsmod,  stateTransitions,...
      obsPrecision, backup, options)

[K,T] = size(yt);

RegionInfo = Info;
Regions = size(Info,1);
RestrictionLevel = 1;
f = zeros(Regions,T);
obsupdate = zeros(K,1);
for r = 1:Regions
    subsetSelect = RegionInfo(r,1):RegionInfo(r,2);
    yslice = yt(subsetSelect,:);
    precisionSlice = obsPrecision(subsetSelect);
    x0 = currobsmod(subsetSelect);
% xt = currobsmod(subsetSelect);
% obsupdate(subsetSelect) = xt;
    factorPrecision = kowStatePrecision(stateTransitions(r), 1, T);
    lastMean = backup{r,1};
    lastHessian = backup{r,2};
    [xt, lastMean, lastHessian] = optimizeA(x0, yslice,...
        precisionSlice,  Factor(r,:), factorPrecision, RestrictionLevel,  lastMean, lastHessian, options);
    obsupdate(subsetSelect) = xt;
    backup{r,1} = lastMean;
    backup{r,2} = lastHessian;
    
    f(r,:) =  kowUpdateLatent(yslice(:),  xt, factorPrecision, precisionSlice);
end


end

