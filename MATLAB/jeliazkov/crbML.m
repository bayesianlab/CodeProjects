function [ z,fz ] = crbML( a,b,mu,sigma, sims, burnin, redrunsims, redburn )
[J,~] = size(sigma);
H = inv(sigma);
precisionDiag = diag(H);
sample = zeros(sims,3,J);
sample(:,1,:) =  ghkGibbsSampler(a,b,mu, sigma, sims);
sample = sample(burnin+1:sims,:,:);
sample(:,3,:)= repmat(sqrt(1./precisionDiag)', sims-burnin, 1);
notj = notJindxs(J);

for s = 1:sims-burnin
    for j = 1:J
        tnj = notj(j,:);
        tsamp = squeeze(sample(s, 1, tnj));
        sample(s, 2, j) = mu(j) - (1/H(j,j))*H(j,tnj)*(tsamp - mu(tnj)');
    end
end
% [z, fz] = crbReducedRun(0, Inf, mu, sigma, sample,redrunsims, redburn);
end

