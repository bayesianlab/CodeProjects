function [ H ] = kowMakeVariance(  stackedTransitions, P0  ,T )
[r,c] = size(P0);
[k, lags] = size(stackedTransitions);
N = (lags-1)*k;
It = speye(T-1);
Ik = [speye(k), zeros(k,N)];
zt = zeros(T-1,1);

p = spdiags(stackedTransitions,[0, k:k:N], k, k*lags);
H = kron( [It, zt], p) + kron( [ zt, It], Ik);

end

