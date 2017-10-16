function [ml, se] = crtSimulator(a, b, mu, sigma, sims, burnin, varargin)
J = length(mu);
precision = inv(sigma);   
conditionalVars = diag(precision);
yDim = 1:J;
sample = zeros(sims, 3, J);

if nargin > 6
    sample(1,1,:) = varargin{1};
else
    disp('using random draws')
    sample(1,1,:) = mvnrnd(mu, precision);
end

for sim = 2:(sims)
    for j = yDim
        blockIndices = yDim(j ~= yDim);
        Hxx = conditionalVars(j);
        Hyx = precision(j, blockIndices);
        sigmaxx = sqrt(Hxx^(-1));
        xNotj = squeeze(sample(sim-1, 1, blockIndices))';
        muNotj = mu(blockIndices);
        muj = conditionalMeanMVN(mu(j), Hxx, Hyx, xNotj, muNotj);
        sample(sim, :, j) = [tnormrnd(a,b, muj, sigmaxx), muj, sigmaxx];
    end
end
sample
sample = sample(burnin+1:sims,:,:);
zStar = squeeze(mean(sample(:, 1, :)))'

K = transitionKernel(a,b,zStar, sample, mu, precision, conditionalVars);
mvnpdf(zStar, mu, sigma)
mean(prod(K,2))
mvnpdf(zStar, mu, sigma)/mean(prod(K,2))
ml = log(mvnpdf(zStar, mu, sigma)/mean(prod(K,2)));
se = lpVarCRT(sample, 25, a,b,mu,sigma,precision);
end