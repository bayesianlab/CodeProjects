function [P0, Phi, G] = initCovar(params)

[K,lags] = size(params);
dis = (0:lags-1)*K;
Phi = full(spdiags(params, dis, K, K*lags));
G = [Phi;eye( (lags-1)*K),zeros( (lags-1)*K, K)];
PhiKronPhi = kron(G,G);
Im = speye(size(PhiKronPhi,1));
R = full(spdiags(ones(K), 0, K*lags,K));
RRT = R*R';
P0 = (Im - PhiKronPhi)\RRT(:);
P0 = reshape(P0, K*lags,K*lags);
end

