function [factors] = kowUpdateRegionFactor(ydemut,...
    obsEqnPrecision, regionObsModel, RegionAr, regionIndices,T)

Regions = size(RegionAr,1);
factors = zeros(Regions, T);
for r= 1:Regions
    bdex = regionIndices(r, 1);
    edex = regionIndices(r, 2);
    ycslice = ydemut(bdex:edex, :);
    obsPrecisionSlice = obsEqnPrecision(bdex:edex);
    obsslice = regionObsModel(bdex:edex);
    [Sregionprecision] = kowMakeVariance(RegionAr(r,:), 1, T);
    factors(r,:) = kowUpdateLatent(ycslice(:), obsslice,...
        Sregionprecision,obsPrecisionSlice)';
end
end

