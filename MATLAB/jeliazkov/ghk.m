function [ lp ] = ghk( N, sims, J, mu, sigma )
C = chol(sigma, 'lower');
L = tril(C, -1);  
djj = diag(C)';

% sims and N ?
eta = zeros(N,J);
uHat = unifrnd(0,1, sims,J);
simResults = zeros(N, sims);
for s =1:sims
    for j = 1:J
        meanUpdate = (mu(j) + (L(j,:)*eta')')/djj(j);
        Fa = normcdf(-meanUpdate,0,1);
        uFbMinusFa = uHat(s, j)*normcdf(meanUpdate,0,1);
        eta(j) = norminv(Fa + uFbMinusFa,0,1);
    end
    jMeans = (mu + (L*eta')')./djj;
    simResults(1,s)= prod(normcdf(jMeans));
end
lp = logProbability(sims, simResults);
end

