function [obsupdate,lastMeanUpdate,lastHessianUpdate,f  ] =...
    kowRegionBlocks( yt,precision,RegionObsModel,...
        StateTransitions, CountriesThatStartRegions,...
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
                ObsPriorMean,ObsPriorVar, factor, yslice, i, burnin);
        saveStatePrecisions(:,:,regionselect) = StatePrecision;

    else
        Restricted =0;
        [obsupdate(selectC),lastMeanUpdate(:,b), lastHessianUpdate(:,:,b)] =...
            kowObsModelUpdate(guess, pslice, StatePrecision, lastMean(:,b),...
                lastHessian(:,:,b), Restricted, PriorPre, logdetPriorPre,...
                ObsPriorMean,ObsPriorVar, factor, yslice, i, burnin);
    end
end
f = zeros(NF, T);

for i = 1:NF
    f(i,:) = kowUpdateLatent(yt(:), obsupdate,saveStatePrecisions(:,:,i), precision);
end
end

