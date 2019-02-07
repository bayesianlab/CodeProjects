function [IR, IC, Regions, Countries] = MakeObsModelIdentity( InfoMat, SeriesPerCountry)
Countries = size(InfoMat,1);
K = Countries*SeriesPerCountry;
Countries = K/SeriesPerCountry;
Regions = length(unique(InfoMat(:,1)));
CountriesInRegion = Countries / Regions;
IC = kron(eye(Countries), ones(SeriesPerCountry,1));

IR = zeros(K,Regions);
Expanded = kron(InfoMat, ones(SeriesPerCountry,1));
for r = 1:Regions
    Ir(:,r) = double(r == Expanded);
    
end

end

