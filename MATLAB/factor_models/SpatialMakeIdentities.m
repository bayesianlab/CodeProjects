function [I1,I2] = SpatialMakeIdentities(K, nEqnsPerSeries, nSpatialFactors)
I1 = ones(K,1);
I2 = kron(ones(nEqnsPerSeries,1), eye(nSpatialFactors));
end

