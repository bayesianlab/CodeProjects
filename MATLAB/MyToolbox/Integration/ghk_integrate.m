function [prob] = ghk_integrate(y, Xbeta, Sigma, Sims)
%% ghk_integrate help notes:
% y must come in as y1 y2 ...yT, y1 = (y11 y21 ... yK1)^T 
% Similar Xbeta must be the mean of y and come in with the same rows and 
% columns as y. 
[K,T]=size(Xbeta);
si = 2.*y-1;
L = chol(Sigma,'lower');
offDiag = tril(L, -1);
djj = diag(L);
djj2 = djj.^2;
cij = zeros(K,T,Sims);
estProb = zeros(T, Sims);
uHat = unifrnd(0,1, K,T,Sims);
for t = 1:T
    fprintf('T = %i\n', t)
    mu = Xbeta(:,t);
    tsi = si(:,t);
    for s = 1:Sims
        te = zeros(K,1);
        for k = 1:K
            meanUpdate = tsi(k)*(mu(k) + (offDiag(k,:)*te))/djj(k);
            te(k) = tsi(k)*oneSidedTruncatedNormal(-meanUpdate);
            cij(k,t,s) = normcdf(meanUpdate);
        end
        estProb(t,s) = prod(cij(:,t,s));
    end
    
end
prob = -log(Sims) + log(sum(estProb,2));
end

