function [IdentityCell, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell)


getK = InfoCell{1,1};
K = getK(end,end);
sectors = length(InfoCell);
sectorInfo = zeros(1,sectors);
IdentityCell = cell(1,sectors);
for s = 1:sectors
    Info = InfoCell{1,s};
    cols = size(Info,1);
    sectorInfo(s) = cols;
    I = zeros(K,cols);
    for r = 1:cols
        index = Info(r,:);
        I(index(1):index(2),r) = 1;
    end
    IdentityCell{1,s} = I;
end

factorInfo = factorIndices(sectorInfo);
end

