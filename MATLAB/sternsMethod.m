clear; clc;
simulation_data_mvp
sims = 100;
[vect, vals] = eig(sigma);
smallestEigen = min(diag(vals));
eps = smallestEigen + .0001;


simResults = zeros(sims,1);
varianceMat = (sigma - (smallestEigen+eps)*eye(J));
for i = 1:sims
    nu = mvnrnd(mu1, varianceMat, N, J);
    vals = normcdf(nu./sqrt(smallestEigen));
    simResults(i) = prod(vals);
end
log(simResults)

