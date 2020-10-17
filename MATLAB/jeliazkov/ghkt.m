function [variates] = ghkt(centrality, shape, df, Constraints, N)
[K,~]=size(centrality);
L = chol(shape,'lower');
offDiag = tril(L, -1);
djj = diag(L);
xij = zeros(K,N);
w = sqrt(df./chi2rnd(df, 1, N));
for s = 1:N
    te = zeros(K,1);
    for k = 1:K
        if Constraints(k) == 0
            meanUpdate = (centrality(k) + (offDiag(k,:)*te))/(w(s)*djj(k));
            xij(k,s) = normrnd(meanUpdate, djj(k));
        else
            meanUpdate = -Constraints(k)*(centrality(k) + (offDiag(k,:)*te))/(w(s)*djj(k));
            te(k) = Constraints(k)*tmvn_epsilonball(meanUpdate,1);
            xij(k,s) = te(k);
        end
    end
end
variates = centrality + w.*(L*xij);
end

