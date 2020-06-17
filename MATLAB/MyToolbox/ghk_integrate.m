function [prob] = ghk_integrate(y, Xbeta, Sigma, Sims)
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

