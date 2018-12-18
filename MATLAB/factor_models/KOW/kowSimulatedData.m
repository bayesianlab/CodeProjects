
K = 20;
Regions = 2;
RegionIndices = [1,10;11,20];
beta = ones(K,1);
G = [ones(K,1)*.2, ones(K,1).*.6, ones(K,1).*(-.5)];

kowMakeObsModelIdentityMatrices(K, RegionIndices, 
