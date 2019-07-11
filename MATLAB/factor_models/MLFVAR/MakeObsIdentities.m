function [IdentityMat] = MakeObsIdentities( InfoCell,  K)
nlevels = size(InfoCell,2);
nFactors =0;
for q = 1:nlevels
    nFactors = nFactors + size(InfoCell{1,q},1);
end
InfoCell
IdentityMat = zeros(K, nFactors);
spast = 0;
for c = 1:nlevels
    Indices = InfoCell{1,c};
    Sectors = size(Indices,1);
    for s = 1:Sectors
        range = Indices(s,1):Indices(s,2);
        IdentityMat(range,spast + s) = 1;
    end
    spast = spast + Sectors;
end
end
