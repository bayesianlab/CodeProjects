function [factors] = kowUpdateCountryFactor(ydemut,...
    obsEqnPrecision, countryObsModel, CountryAr, Countries,...
    SeriesPerCountry,T)
t = 1:SeriesPerCountry;
countryEye = eye(SeriesPerCountry);
factors = zeros(Countries, T);
for c= 1 :Countries
    selcoun = t + (c-1)*SeriesPerCountry;
    ycslice = ydemut(selcoun, :);
    obsPrecisionSlice = obsEqnPrecision(selcoun);
    obsslice = countryObsModel(selcoun);
    [Scountryprecision] = kowMakeVariance(CountryAr(c,:), 1, T);
    factors(c,:) = kowUpdateLatent(ycslice(:), obsslice, Scountryprecision,...
        obsPrecisionSlice)';
end
end

