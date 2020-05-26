function [P0, Phi, G,notvalid] = initCovar(params, sigmau)
%% sigmau is a row
% params = [ gamma_world_lag1, gamma_world_lag2, ..., gamma_world_lagP; 
%                       gamma_region_lag1,...,gamma_region_lagP; 
% ...
%                       ...]
K=length(sigmau);
[K1,lags] = size(params);
if K ~=K1
    error('sigmau needs to have same number of rows as params.')
end
dis = (0:lags-1)*K;
Phi = full(spdiags(params, dis, K, K*lags));
G = [Phi;eye( (lags-1)*K),zeros( (lags-1)*K, K)];
notvalid=0;
PhiKronPhi = kron(G,G);
Im = eye(size(PhiKronPhi,1));
R = spdiags(sigmau, 0, K*lags,K);
RRT = R*R';
P0 = ((Im - PhiKronPhi)\RRT(:));
P0 = reshape(P0, K*lags,K*lags);
[~,p] = chol(P0);
if p ~= 0 
    notvalid = 1;
end
end

