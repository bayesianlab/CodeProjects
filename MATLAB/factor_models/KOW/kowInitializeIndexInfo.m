function [K,T,betaDim, EqnsPerBlock, RegionIndicesInFt, CountryIndicesInFt, nFactors] =...
    kowInitializeIndexInfo(yt, Xt, blocks, RegionIndices, Countries)
[K,T] = size(yt);
betaDim=size(Xt,2);
Regions = size(RegionIndices,1);
EqnsPerBlock = K/blocks;
RegionIndicesInFt = 1 + (1:Regions);
CountryIndicesInFt = 1 + Regions + (1:Countries);
nFactors = 1 + Regions + Countries;
end

