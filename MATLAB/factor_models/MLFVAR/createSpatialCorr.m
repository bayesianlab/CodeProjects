function [R, L] = createSpatialCorr(DistanceMat, parama, corrType)
if corrType == 1
    % Nearest Neighbor
    r = size(DistanceMat,1);
    A = eye(r) - (parama.*DistanceMat);
    dA = diag(diag(A).^(-.5));
    R = dA*A*dA;
else
    % Euclidean Distance
    R = exp(-parama*DistanceMat);
end
L = chol(R, 'lower');
end

