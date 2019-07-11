function [obsupdate,lastMeanUpdate,lastHessianUpdate,f  ] =...
    kowRegionBlocks( yt,precision,RegionObsModel,...
        StateTransitions, RegionIndices, lastMean, lastHessian,...
        ObsPriorMean,ObsPriorVar, factor, i, burnin, CountriesThatStartRegions )
fprintf(' Region... ')
[K,T] = size(yt);
blockNumber = size(lastMean,2);
blockSize = K/blockNumber;
NF = length(StateTransitions);
saveStatePrecisions = zeros(T,T,NF);
lastMeanUpdate = zeros(size(lastMean,1), size(lastMean,2));
lastHessianUpdate = zeros(size(lastHessian,1), size(lastHessian,2), size(lastHessian,3));
obsupdate = zeros(length(RegionObsModel),1);
regioncount = 1;
regionselect = 0;
t = 1:blockSize;
for b = 1:blockNumber
    selectC = t + blockSize*(b-1);
    guess = RegionObsModel(selectC);
    yslice = yt(selectC, :);
    pslice = precision(selectC, :);
    if b == CountriesThatStartRegions(regioncount) 
        Restricted = 1;
        regioncount = regioncount + 1;
        regionselect = regionselect + 1;
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

