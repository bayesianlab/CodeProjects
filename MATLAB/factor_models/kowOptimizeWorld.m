function [ll] = kowOptimizeWorld(worldguess, ydemu, StateVariance, obsVariance, K, T)
speyet = speye(T);
A = kron(speyet, worldguess);
V = A*StateVariance*A' + obsVariance;
ll = logmvnpdf(ydemu', zeros(1, T*K), V);
end

