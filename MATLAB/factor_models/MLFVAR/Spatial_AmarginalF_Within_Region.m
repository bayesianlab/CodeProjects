function [obsupdate, backup, f, vdecomp] = Spatial_AmarginalF_Within_Region(Info, Factor, yt, currobsmod,  stateTransitions, factorVariance,...
    obsPrecision, backup, options, identification, vy)
% within region ys
[K,T] = size(yt);
Regions = size(Info,1);
f = zeros(Regions,T);
obsupdate = zeros(K,1);
u = 0;
vdecomp = zeros(K,1);
for r = 1:Regions
    subsetSelect = Info(r,:);
    yslice = yt(subsetSelect,:);
    vytemp = vy(subsetSelect);
    precisionSlice = obsPrecision(subsetSelect);
    x0 = currobsmod(subsetSelect);
    factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
    lastMean = backup{r,1};
    lastHessian = backup{r,2};
    [xt, lastMean, lastHessian] = optimizeA(x0, yslice,...
        precisionSlice,  Factor(r,:), factorPrecision, lastMean, lastHessian, options, identification);
    obsupdate(subsetSelect) = xt;
    backup{r,1} = lastMean;
    backup{r,2} = lastHessian;    
    f(r,:) =  kowUpdateLatent(yslice(:),  xt, factorPrecision, precisionSlice);
    obsmodSquared = xt.^2;
    
    for m = 1:size(yslice,1)
        u = u + 1;
        vdecomp(u) = (obsmodSquared(m) .* var(f(r,:))) ./ vytemp(m);
    end
    
end
end


