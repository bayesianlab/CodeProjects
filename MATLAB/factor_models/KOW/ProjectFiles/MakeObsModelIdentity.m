function [IR, IC, Regions, Countries] = MakeObsModelIdentity( InfoMat, SeriesPerCountry)
Countries = size(InfoMat,1);
Regions = length(unique(InfoMat(1,:)));
Neqns = SeriesPerCountry * Countries;
IR = zeros(Neqns, Regions);
IC = kron(eye(Countries), ones(SeriesPerCountry,1));
r = InfoMat(1,1);
changeColumn = 1;
t = 1:SeriesPerCountry;
for i = 1:Countries
    putin = t + SeriesPerCountry*(i-1);
    if r == InfoMat(i,1)
        IR(putin, changeColumn) = 1;
    else
        r = InfoMat(i,1);
        changeColumn = changeColumn + 1;
        IR(putin, changeColumn) = 1;
    end
    
end
end

