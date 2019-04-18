function [R] = createSpatialCorr(DistanceMat, parama)
r = size(DistanceMat,1);
A = eye(r) - (parama.*DistanceMat);
dA = diag(diag(A).^(-.5));
R = dA*A*dA;
end

