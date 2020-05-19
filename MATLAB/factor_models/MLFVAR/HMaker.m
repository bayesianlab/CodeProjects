function [H] = HMaker(Gamma,T)
% More general block diagonal matrix maker
% Gamma must be in state space form. 
% Can handle multivariate dense Gammas. 
[K, Col ] = size(Gamma);
Padding = [eye(K), zeros(K,Col-K)];
OffDiag = spdiags(-ones(T,1), -1, T,T);
G = full(kron(OffDiag, Gamma));
H = kron(eye(T), Padding)+G;
end

