function [f, vdecomp] = FgivenA(Info, yt, currobsmod,  stateTransitions, factorVariance,...
    obsPrecision,  vy)
[K,T] = size(yt);
Regions = size(Info,1);
f = zeros(Regions,T);
u = 0;
vdecomp = zeros(K,1);
for r = 1:Regions
    subsetSelect = Info(r,1):Info(r,2);
    yslice = yt(subsetSelect,:);
    vytemp = vy(subsetSelect);
    precisionSlice = obsPrecision(subsetSelect);
    x0 = currobsmod(subsetSelect);
    factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
    
    f(r,:) =  kowUpdateLatent(yslice(:),  x0, factorPrecision, precisionSlice);
    
    obsmodSquared = x0.^2;
    
    for m = 1:size(yslice,1)
        u = u + 1;
        vdecomp(u) = (obsmodSquared(m) .* var(f(r,:))) ./ vytemp(m);
    end
end
end

