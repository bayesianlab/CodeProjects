function [ lp,se ] = ghk( sims, J, mu, sigma )
C = chol(sigma, 'lower');
L = tril(C, -1);  
djj = diag(C)';

eta = zeros(1,J);
uHat = unifrnd(0,1, sims,J);
simResults = zeros(sims,1);
for s =1:sims
    for j = 1:J
        meanUpdate = (mu(j) + (L(j,:)*eta')')/djj(j);
        Fa = normcdf(-meanUpdate,0,1);
        uFbMinusFa = uHat(s, j)*normcdf(meanUpdate,0,1);
        eta(j) = norminv(Fa + uFbMinusFa,0,1);
    end
    jMeans = (mu + (L*eta')')./djj;
    simResults(s,1)= prod(normcdf(jMeans));
end
lp = logProbability(sims, simResults);
se = lpVarGHK(simResults,25);
end

