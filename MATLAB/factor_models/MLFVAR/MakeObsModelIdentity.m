function [IR, IC, Regions, Countries] = MakeObsModelIdentity( InfoMat, SeriesPerCountry)
Countries = size(InfoMat,1);
Neqns = Countries*SeriesPerCountry;
Countries = Neqns/SeriesPerCountry;
Regions = length(unique(InfoMat(:,1)));
CountriesInRegion = Countries / Regions;
IC = kron(eye(Countries), ones(SeriesPerCountry,1));

IR = kron(eye(Regions), ones(SeriesPerCountry*CountriesInRegion,1)).*...
    kron(ones(length(InfoMat),1), ones(SeriesPerCountry,1));
end

