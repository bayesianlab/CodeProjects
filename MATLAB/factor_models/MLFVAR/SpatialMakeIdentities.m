function [I1,I2,factorInfo] = SpatialMakeIdentities(K, nEqnsPerSeries, nSpatialFactors)
I1 = ones(K,1);
I2 = kron(ones(nEqnsPerSeries,1), eye(nSpatialFactors));
factorInfo = [1,size(I1,2); size(I1,2)+1,size(I2,2)+size(I1,2)];
end

