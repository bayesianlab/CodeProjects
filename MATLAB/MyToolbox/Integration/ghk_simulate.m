function [sims] = ghk_simulate(Constraints, mu, Sigma, Sims)
[K,T]=size(mu);
L = chol(Sigma,'lower');
offDiag = tril(L, -1);
djj = diag(L);
xij = zeros(K,Sims);

for s = 1:Sims
    te = zeros(K,1);
    for k = 1:K
        if Constraints(k) == 0
            meanUpdate = (mu(k) + (offDiag(k,:)*te))/djj(k);
            xij(k,s) = normrnd(meanUpdate, djj(k));
        else
            meanUpdate = -Constraints(k)*(mu(k) + (offDiag(k,:)*te))/djj(k);
            te(k) = Constraints(k)*tmvn_epsilonball(meanUpdate,1);
            xij(k,s) = te(k);
        end
    end
end
sims = mu + L*xij;
end

