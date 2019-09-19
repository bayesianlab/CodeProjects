function [obsupdate, backup, f] = ...
    AmarginalF_ML(Info, Factor, yt, currobsmod,  stateTransitions, factorVariance,...
    obsPrecision, backup,  identification)

[K,T] = size(yt);
Regions = size(Info,1);
f = zeros(Regions,T);
obsupdate = zeros(K,1);

%     u = 0;
%     vdecomp = zeros(K,1);
for r = 1:Regions
    subsetSelect = Info(r,1):Info(r,2);
    ySlice = yt(subsetSelect,:);
%     vytemp = vy(subsetSelect);
    precisionSlice = obsPrecision(subsetSelect);
    x0 = currobsmod(subsetSelect);
    factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
    lastMean = backup{r,1};
    lastCovar = backup{r,2};
    [xt, lastMean, lastCovar] = identification2_ml(x0(2:end), ySlice(2:end,:),precisionSlice(2:end),...
        Factor(r,:), factorPrecision, lastMean,...
        lastCovar);

    obsupdate(subsetSelect) = xt;
    backup{r,1} = lastMean;
    backup{r,2} = lastCovar;
    
    f(r,:) =  kowUpdateLatent(ySlice(:), xt, factorPrecision, precisionSlice);
    
    %         obsmodSquared = xt.^2;
    %
    %         for m = 1:size(ySlice,1)
    %             u = u + 1;
    %             vdecomp(u) = (obsmodSquared(m) .* var(f(r,:))) ./ vytemp(m);
    %         end
end
end

