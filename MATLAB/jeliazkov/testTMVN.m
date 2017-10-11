function [ sample] = testTMVN(a, b, mu, sigma, sims)
% Geweke 1991. Draws from a truncated multivariate normal
% distribution. 
J = length(mu);
precision = inv(sigma);
conditionalVars = diag(precision);
yDim = 1:J;
sample = zeros(sims, J);

for sim = 2:(sims)
    for j = yDim
        blockIndices = yDim(j ~= yDim);
        Hxx = conditionalVars(j);
        Hyx = precision(j, blockIndices);
        sigmaxx = sqrt(Hxx^(-1));
        xNotj = sample(sim-1, blockIndices);
        muNotj = mu(blockIndices);
        muj = conditionalMeanMVN(mu(j), Hxx, Hyx, xNotj, muNotj);
        sample(sim, j) = tnormrnd(a,b, muj, sigmaxx);
    end
end
end

