function [ K, zStar ] = crtML(a, b, mu, sigma, sims, burnin, varargin)
J = length(mu);
L = chol(sigma, 'lower');
H = inv(sigma);
notj = notJindxs(J);
sample = zeros(sims, 3, J);

if nargin > 6
    sample(1,1,:) = varargin{1};
else
    disp('using random draws')
    sample(1,1,:) = mvnrnd(mu, sigma);
end

sample(:,1,:) = (L*ghkGibbsSampler(a, b, mu, sigma, sims)' + mu')';
sample = sample(burnin+1:sims,:,:);
for s = 1:sims-burnin
    for j = 1:J
        tnj = notj(j,:);
        tsamp = squeeze(sample(s, 1, tnj));
        sample(s, 2, j) = mu(j) - (1/H(j,j))*H(j,tnj)*(tsamp - mu(tnj)');
    end
end
precisionDiag = diag(H);
sample(:,3,:)= repmat(sqrt(1./precisionDiag)', sims-burnin, 1);
zStar = squeeze(mean(sample(:, 1, :)))';
K = transitionKernel(a,b,zStar, sample, mu, H, precisionDiag);
end
