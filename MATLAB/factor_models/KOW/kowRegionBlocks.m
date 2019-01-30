function [obsupdate,lastMeanUpdate,lastHessianUpdate,f  ] =...
    kowRegionBlocks( yt,precision,RegionObsModel,...
        StateTransitions, RegionIndices, lastMean, lastHessian,...
        ObsPriorMean,ObsPriorVar, factor, i, burnin )
fprintf(' Region... ')
[K,T] = size(yt);
blockNumber = size(RegionIndices,1);
blockSize = K/blockNumber;
NF = length(StateTransitions);
saveStatePrecisions = zeros(T,T,NF);
lastMeanUpdate = zeros(blockSize, blockNumber);
lastHessianUpdate = zeros(blockSize, blockSize, blockNumber);
obsupdate = zeros(length(RegionObsModel),1);
regioncount = 1;
regionselect = 0;
t = 1:blockSize;
for b = 1:blockNumber
    indices = RegionIndices(b,:);
    selectC = indices(1):indices(2);
    guess = RegionObsModel(selectC);
    yslice = yt(selectC, :);
    pslice = precision(selectC, :);
%     if b == CountriesThatStartRegions(regioncount) 
    if b > 0 
        Restricted = 1;
        regioncount = regioncount + 1;
        regionselect = regionselect + 1;
        StateTransitions(regionselect,:)
        [StatePrecision] = kowStatePrecision(StateTransitions(regionselect,:), 1, T);
        [obsupdate(selectC),lastMeanUpdate(:,b),lastHessianUpdate(:,:,b)] =...
            kowObsModelUpdate(guess, pslice, StatePrecision, lastMean(:,b),...
                lastHessian(:,:,b), Restricted,ObsPriorMean(selectC),...
                ObsPriorVar(selectC,selectC), factor(regionselect,:), yslice, i, burnin);
         saveStatePrecisions(:,:,regionselect) = StatePrecision;

    else
        Restricted =0;
        [obsupdate(selectC),lastMeanUpdate(:,b), lastHessianUpdate(:,:,b)] =...
            kowObsModelUpdate(guess, pslice, StatePrecision, lastMean(:,b),...
                lastHessian(:,:,b), Restricted, ObsPriorMean(selectC),...
                ObsPriorVar(selectC,selectC), factor(regionselect,:), yslice, i, burnin);
    end
end
f = zeros(NF, T);

for i = 1:NF
    select = RegionIndices(i,:);
    yvec = yt(select(1):select(2), :);
    yvec = yvec(:);
    f(i,:) = kowUpdateLatent(yvec, obsupdate(select(1):select(2)),...
        saveStatePrecisions(:,:,i), precision(select(1):select(2)));
end
end

