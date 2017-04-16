% GHK simulator
% multivariateProbit
simulation_data_mvp
L = chol(sigma, 'lower');
sims = 1000;
L = tril(C, -1)
djj = diag(C)';
eta = zeros(N,J);
uHat = unifrnd(0,1, sims,J);
simResults = zeros(N, 1);
for s =1:sims
    for j = 1:J
        meanUpdate = (mu1(j) + (L(j,:)*eta')')/djj(j);
        Fa = normcdf(-meanUpdate,0,1);
        uFbMinusFa = uHat(s, j)*normcdf(meanUpdate,0,1);
        eta(j) = norminv(Fa + uFbMinusFa,0,1);
    end
    jMeans = (mu1 + (L*eta')')./djj;
    simResults(s,1)= prod(normcdf(jMeans));
end
maxSim = max(simResults);
weight = (1/(sims*maxSim));
log(weight*sum(simResults)*maxSim)



