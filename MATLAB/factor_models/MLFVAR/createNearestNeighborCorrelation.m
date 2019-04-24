function [R] = createNearestNeighborCorrelation(D, x)
ImA =  eye(size(D,1)) - (x.*D);
t = diag(diag(ImA).^(-.5));
R = t*ImA*t;
end

