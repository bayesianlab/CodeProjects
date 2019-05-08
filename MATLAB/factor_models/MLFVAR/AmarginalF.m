function [obsupdate, backup, f, vdecomp] = ...
    AmarginalF(Info, Factor, yt, currobsmod,  stateTransitions, factorVariance,...
    obsPrecision, backup, options, identification, vy, mut)

[K,T] = size(yt);
Regions = size(Info,1);
f = zeros(Regions,T);
obsupdate = zeros(K,1);
u = 0;
vdecomp = zeros(K,1);
for r = 1:Regions
    subsetSelect = Info(r,1):Info(r,2);
    yslice = yt(subsetSelect,:);
    muslice = mut(subsetSelect,:);
    vytemp = vy(subsetSelect);
    precisionSlice = obsPrecision(subsetSelect);
    x0 = currobsmod(subsetSelect);
    factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
    lastMean = backup{r,1};
    lastCovar = backup{r,2};
    [xt, lastMean, lastCovar] = optimizeA(x0, yslice,...
        precisionSlice,  Factor(r,:), factorPrecision, lastMean, lastCovar, options, identification);
    obsupdate(subsetSelect) = xt;
       
    backup{r,1} = lastMean;
    backup{r,2} = lastCovar;
    
    f(r,:) =  kowUpdateLatent(yslice(:) - muslice(:),  xt, factorPrecision, precisionSlice);
    
    obsmodSquared = xt.^2;
    
    for m = 1:size(yslice,1)
        u = u + 1;
        vdecomp(u) = (obsmodSquared(m) .* var(f(r,:))) ./ vytemp(m);
    end
end
end