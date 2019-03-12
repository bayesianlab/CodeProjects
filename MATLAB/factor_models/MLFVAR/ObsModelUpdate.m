function [obsupdate, backup] = ...
    ObsModelUpdate(Info, Ft, yt, currobsmod,  stateTransitions,...
      obsPrecision, backup, options, blockIndices)

[K,T] = size(yt);
blocks = size(blockIndices);
RestrictionInfo = Info{1,1};
FactorInfo = Info{1,2};
levels = size(RestrictionInfo,2);
obsupdate = zeros(K,levels);
for r = 1:blocks
    subsetSelect = blockIndices(r,1):blockIndices(r,2);
    factorIndices = FactorInfo(r,:);
    RestrictedIndices = find(RestrictionInfo(r,:), levels);
    yslice = yt(subsetSelect,:);
    precisionSlice = obsPrecision(subsetSelect);
    x0 = currobsmod(subsetSelect,:);
    
    factorPrecision = kowStatePrecision(diag(stateTransitions(factorIndices)), 1, T);
    lastMean = backup{r,1};
    lastHessian = backup{r,2};
    Ftslice = Ft(factorIndices,:);
    [xt, lastMean, lastHessian] = drawProposal(x0, yslice,...
        precisionSlice, Ftslice, factorPrecision, ...
        lastMean, lastHessian, RestrictedIndices, options);
    obsupdate(subsetSelect,:) = xt;
    backup{r,1} = lastMean;
    backup{r,2} = lastHessian;
    
    
end


end

