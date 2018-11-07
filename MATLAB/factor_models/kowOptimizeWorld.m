function [ll] = kowOptimizeWorld(worldguess, ydemu, StateVariance, obsPrecision, statePrecision, K, T)

speyet = speye(T);
Pinv = (statePrecision + spdiags(repmat(worldguess'*worldguess,T,1), 0, T,T)) \eye(T);
A = kron(speyet, worldguess);
Ao = diag(obsPrecision)*worldguess;
BigA = kron(speyet, Ao);
U = spdiags(repmat(obsPrecision, T,1),0,K*T, K*T) - BigA * Pinv * BigA';

py = U*ydemu;

size(py)
size(StateVariance)
size(A)
2*py'* StateVariance*A * py
% scr = zeros(K,1);
% for k = 1 : K
%     der = zeros(K,1);
%     der(k) = worldguess(k);
%     BigD = kron(speyet, der);
%     scr(k ) = py' * BigD * StateVariance * A'* py  - trace(U * A * StateVariance * BigD');
% end
% scr
% scr*scr'
% chol(scr*scr')
% A = kron(speyet, worldguess);
% V = A*StateVariance*A' + obsPrecision;
% ll = logmvnpdf(ydemu', zeros(1, T*K), V);
end

