function [M, nRegionFactors] = setRegionalIndices(regionalIdentity, SeriesPerY)
nRegionFactors= size(regionalIdentity,2);
M = zeros(nRegionFactors, SeriesPerY);
for h = 1:nRegionFactors
    M(h,: ) = find(regionalIdentity(:,h) == 1)';
end
end

