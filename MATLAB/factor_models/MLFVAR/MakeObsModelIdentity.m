function [IR, IC, Regions, Countries] = MakeObsModelIdentity( InfoMat, SeriesPerCountry)
Countries = size(InfoMat,1);
K = Countries*SeriesPerCountry;
Countries = K/SeriesPerCountry;
Regions = length(unique(InfoMat(:,1)));
IC = kron(eye(Countries), ones(SeriesPerCountry,1));

IR = zeros(K,Regions);
Expanded = kron(InfoMat, ones(SeriesPerCountry,1));
for r = 1:Regions
    IR(:,r) = double(r == Expanded);  
end

end

