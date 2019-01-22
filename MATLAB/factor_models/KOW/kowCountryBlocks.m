function [obsupdate, lastMeanUpdate, lastHessianUpdate,f ] =...
    kowCountryBlocks(yt, precision, CountryObsModel, StateTransitions,...
    SeriesPerCountry, Countries, lastMean, lastHessian, PriorPre, logdetPriorPre,ObsPriorMean,ObsPriorVar, factor, i, burnin)
NF = length(StateTransitions);
T = size(yt,2);
saveStatePrecisions = zeros(T,T,NF);
obsupdate = zeros(length(CountryObsModel),1);
lastMeanUpdate = zeros(SeriesPerCountry, Countries);
lastHessianUpdate = zeros(SeriesPerCountry, SeriesPerCountry, Countries);
t = 1:SeriesPerCountry;
Restricted = 1;
for c = 1:Countries
    StatePrecision = kowStatePrecision(StateTransitions(c), 1, T);
    selcoun = t + (c-1)*SeriesPerCountry;
    yslice = yt(selcoun, :);
    pslice = precision(selcoun);
    guess = CountryObsModel(selcoun);
    [obsupdate(selcoun), lastMeanUpdate(:,c), lastHessianUpdate(:,:,c)] = ...
        kowObsModelUpdate(guess, pslice, StatePrecision, lastMean(:,c),...
           lastHessian(:,:,c), Restricted, PriorPre, logdetPriorPre,...
           ObsPriorMean,ObsPriorVar, factor, yslice, i, burnin);
       
    saveStatePrecisions(:,:,c) = StatePrecision;
end
f = zeros(NF, T);
for i = 1:NF
    f(i,:) = kowUpdateLatent(yt(:), obsupdate, saveStatePrecisions(:,:,i), precision);
end
end

