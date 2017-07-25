function [ output_args ] = crbML( a,b,mu,sigma, sims, burnin )
[J,~] = size(sigma);
L = chol(sigma, 'lower');
H = inv(sigma);
precisionDiag = diag(H);
sample = zeros(sims,3,J);
sample(:,1,:) = (L*ghkGibbsSampler(a,b,mu, sigma, sims)' + mu')';
sample(:,3,:)= repmat(sqrt(1./precisionDiag)', sims, 1);
notj = notJindxs(J);
for s = 1:sims
    for j = 1:J
        tnj = notj(j,:);
        tsamp = squeeze(sample(s, 1, tnj));
        sample(s, 2, j) = mu(j) - (1/H(j,j))*H(j,tnj)*(tsamp - mu(tnj)');
    end
end
sample
[z, fz] = crbMarginalLikelihood(0, Inf, mu, H, sample,burnin)

end

