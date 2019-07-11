function [obsupdate, lastMeanUpdate, lastHessianUpdate,f ] =...
    kowCountryBlocks(yt, precision, CountryObsModel, StateTransitions,...
    SeriesPerCountry, Countries, lastMean, lastHessian, ObsPriorMean,ObsPriorVar, factor, i, burnin)
fprintf('Country...')
T = size(yt,2);
saveStatePrecisions = zeros(T,T,Countries);
obsupdate = zeros(length(CountryObsModel),1);
lastMeanUpdate = zeros(SeriesPerCountry, Countries);
lastHessianUpdate = zeros(SeriesPerCountry, SeriesPerCountry, Countries);
t = 1:SeriesPerCountry;
Restricted = 1;
for c = 1:Countries
    StateTransitions(c)
    StatePrecision = kowStatePrecision(StateTransitions(c), 1, T);
    selcoun = t + (c-1)*SeriesPerCountry;
    yslice = yt(selcoun, :);
    pslice = precision(selcoun);
    guess = CountryObsModel(selcoun);
    [obsupdate(selcoun), lastMeanUpdate(:,c), lastHessianUpdate(:,:,c)] = ...
        kowObsModelUpdate(guess, pslice, StatePrecision, lastMean(:,c),...
           lastHessian(:,:,c), Restricted, ObsPriorMean(selcoun),...
           ObsPriorVar(selcoun,selcoun), factor(c,:), yslice, i, burnin);
    saveStatePrecisions(:,:,c) = StatePrecision;
end
f = zeros(Countries, T);
obsupdate= [1.1528;.5223;-.0847]
for i = 1:Countries
    selcoun = t + (i-1)*SeriesPerCountry;
    yslice = yt(selcoun, :);
    pslice = precision(selcoun);
    obsslice = obsupdate(selcoun);
    f(i,:) = kowUpdateLatent(yslice(:), obsslice, saveStatePrecisions(:,:,i), pslice)
end
end

