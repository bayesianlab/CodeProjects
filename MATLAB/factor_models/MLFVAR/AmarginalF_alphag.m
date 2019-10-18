function [alphag] = AmarginalF_alphag(Info, Factor, yt,  xstar, xg,...
    stateTransitions, factorVariance,...
    obsPrecision, backup)
[K,T] = size(yt);
Regions = size(Info,1);
f = zeros(Regions,T);
obsupdate = zeros(K,1);
alphag = zeros(Regions,1);
df = 15;
for r = 1:Regions
    subsetSelect = Info(r,1):Info(r,2);
    littlek = length(subsetSelect);
    ObsPriorMean = ones(1, littlek-1);
    ObsPriorPrecision = eye(littlek-1);
    ySlice = yt(subsetSelect,:);
    precisionSlice = obsPrecision(subsetSelect);
    factorPrecision = kowStatePrecision(stateTransitions(r), 1./factorVariance(r), T);
    meanA = backup{r,1};
    Covariance = backup{r,2};
    omStar = xstar(subsetSelect);
    LogLikePositive = @(v) LLRestrict (v, ySlice, ObsPriorMean,...
        ObsPriorPrecision, precisionSlice, Factor(r,:), factorPrecision);
    proposalDist = @(q) mvstudenttpdf(q, meanA, Covariance, df);
    
    freeElems = xg(subsetSelect);
    freeElems = freeElems(2:end);
    Num = LogLikePositive(omStar(2:end)) + proposalDist(freeElems');
    Den = LogLikePositive(freeElems) + proposalDist(omStar(2:end)');

    alphag(r)  = min(0,Num - Den) + proposalDist(omStar(2:end)');    
end
end

