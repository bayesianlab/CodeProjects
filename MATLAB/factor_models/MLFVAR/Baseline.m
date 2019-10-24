function [storeBeta] = Baseline(yt, xt, factor, loadings, deltas, gammas, Sims, bn)
[K,T] = size(yt)
[nFactors,  lagsState] = size(gammas);
[~, lagObs] = size(deltas);
dimX = K*(nFactors + 1);



IT = ones(T,1);
loadingPriorMean = ones(dimX,1);
loadingPriorVar = 10.*eye( dimX );
obsVariance = ones(K,1);
X = zeros(K*T, (1 + nFactors)*K);
R = zeros(K*lagObs,T-lagObs);
lagind = 1:lagObs;

%
storeBeta = zeros(dimX, Sims-bn);
for i = 1:Sims
    
    % Sample loadings
    [P0,ssDeltas] = initCovar(deltas);
       
%      [b] = drawBeta(yt, xt,  deltas, loadingPriorMean,...
%          loadingPriorVar, obsVariance);
    mut = reshape(xt*loadings,K,T);
    et = yt-mut;
    drawPhi(yt,et, deltas, obsVariance)
    
    if i > bn
%         storeBeta(:,i-bn) = b;
    end
    
    
end


end

