function [factors] = kowUpdateCountryFactor(ydemut,...
    obsEqnVariances, countryObsModel, CountryAr, Countries,...
    SeriesPerCountry,T)
t = 1:SeriesPerCountry;
countryEye = eye(SeriesPerCountry);
factors = zeros(Countries, T);
for c= 1 :Countries
    selcoun = t + (c-1)*SeriesPerCountry;
    ycslice = ydemut(selcoun, :);
    obsPrecisionSlice = 1./(obsEqnVariances(selcoun));
    obsslice = countryObsModel(selcoun);
    [Scountryprecision] = kowMakeVariance(CountryAr(c,:), 1, T);
    factors(c,:) = kowUpdateLatent(ycslice(:), obsslice, Scountryprecision,obsslice,T)';
end
end

