function [obsupdate,lastMeanUpdate,lastHessianUpdate,f  ] =...
    kowRegionBlocks( yt,precision,RegionObsModel,...
        StateTransitions, RegionIndices, CountriesThatStartRegions,...
        SeriesPerCountry, Countries, lastMean, lastHessian,...
        PriorPre, logdetPriorPre,ObsPriorMean,ObsPriorVar, factor, i, burnin )
T = size(yt,2);
NF = length(StateTransitions);
saveStatePrecisions = zeros(T,T,NF);
lastMeanUpdate = zeros(SeriesPerCountry, Countries);
lastHessianUpdate = zeros(SeriesPerCountry, SeriesPerCountry, Countries);
obsupdate = zeros(length(RegionObsModel),1);
regioncount = 1;
regionselect = 0;
t = 1:SeriesPerCountry;
for b = 1:Countries
    selectC = t + (b-1)*SeriesPerCountry;
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
                lastHessian(:,:,b), Restricted, PriorPre, logdetPriorPre,...
                ObsPriorMean(selectC),ObsPriorVar(selectC,selectC), factor(regionselect,:), yslice, i, burnin);
        saveStatePrecisions(:,:,regionselect) = StatePrecision;

    else
        Restricted =0;
        [obsupdate(selectC),lastMeanUpdate(:,b), lastHessianUpdate(:,:,b)] =...
            kowObsModelUpdate(guess, pslice, StatePrecision, lastMean(:,b),...
                lastHessian(:,:,b), Restricted, PriorPre, logdetPriorPre,...
                ObsPriorMean(selectC),ObsPriorVar(selectC,selectC), factor(regionselect,:), yslice, i, burnin);
    end
end
f = zeros(NF, T);
for i = 1:NF
    select = RegionIndices(i,:);
    yvec = yt(select(1):select(2), :);
    yvec = yvec(:);
    f(i,:) = kowUpdateLatent(yvec, obsupdate(select(1):select(2)),saveStatePrecisions(:,:,i), precision(select(1):select(2)));
end
end

