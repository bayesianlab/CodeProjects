function [pistar] = piAstar(Info, Ft, yt, Ag, Astar, stateTransitions, factorVariance,...
    obsPrecision, backup,  identification)
[K, G] = size(Ag);
Regions = size(Info,1);
alphagtostar = zeros(Regions, G);
alphastartoj = zeros(Regions, G);
df = 15;
for m = 1:G
    for r = 1:Regions
        subsetSelect = Info(r,1):Info(r,2);
        yslice = yt(subsetSelect,:);
        [K,T] = size(yslice);
        precisionSlice = obsPrecision(subsetSelect);
        x0 = Astar(subsetSelect);
        x1 = Ag(subsetSelect, m);
        freeElemsStar = x0(2:end);
        freeElemsg = x1(2:end);
        themean = backup{r,1};
        V = backup{r,2};
        factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
        ObsPriorMean = ones(1, K-1);
        ObsPriorPrecision = eye(K-1);
        LogLikePositive = @(v) LLRestrict (v, yslice,ObsPriorMean,...
            ObsPriorPrecision, precisionSlice, Ft(r,:),factorPrecision);
        proposalDist = @(q) mvstudenttpdf(q, themean, V, df);
        
        
        alphagtostar(r,m) = min(0, LogLikePositive(freeElemsStar) + proposalDist(freeElemsg') - ...
            LogLikePositive(freeElemsg) + proposalDist(freeElemsStar'));
        
        w1 = sqrt(chi2rnd(df,1)/df);
        proposal = themean' + chol(V, 'lower')*normrnd(0,1, K-1,1)./w1;
        alphastartoj(r,m) = min(0, LogLikePositive(proposal) + proposalDist(freeElemsStar') - ...
            LogLikePositive(freeElemsStar) + proposalDist(proposal'));
        
    end
end
pistar  = logAvg(alphagtostar) - logAvg(alphastartoj);
end

