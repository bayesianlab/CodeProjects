function [P0, Phi, G,notvalid] = initCovar(params, sigmau)
%% sigmau is a row
% P0 INCLUDES sigmau
[K,lags] = size(params);
dis = (0:lags-1)*K;
Phi = full(spdiags(params, dis, K, K*lags));
G = [Phi;eye( (lags-1)*K),zeros( (lags-1)*K, K)];
notvalid=0;
PhiKronPhi = kron(G,G);
Im = eye(size(PhiKronPhi,1));
R = spdiags(sigmau', 0, K*lags,K);
RRT = R*R';
P0 = ((Im - PhiKronPhi)\RRT(:));
P0 = reshape(P0, K*lags,K*lags);
[~,p] = chol(P0);
if p ~= 0 
    notvalid = 1;
end

end

