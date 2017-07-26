function [zs, fz] = crbReducedRun(a,b,mu, sigma, X,sims, burn)
% X is the main run results, stored X(dim1->sims, dim2->[sims, mu,sigma], dim3->variable) 
[~,~,J] = size(X);
H = inv(sigma);
zs = zeros(1,J);
means = reshape(mean(X(:, 1, :)), [1,J]);
zs(1) = means(1);
nReducedRuns = J-2;
rrs = zeros(sims, 3, J-1, nReducedRuns);

fz = zeros(1,J);
conditionalVars = diag(H);
rrs(:, 3, :, :) = repmat(sqrt(1./conditionalVars(2:J))', sims, 1, nReducedRuns);

notj = notJindxs(J);
fz = mean(tnormpdf(a,b,X(:,2,1), X(:,3,1),zs(1)));
for rr = 1:nReducedRuns
    zNoStars = rr+1:J;
    tmp = ghkGibbsSampler(a,b, mu, sigma, sims);
    rrs(:,1, :, rr) = tmp(:,2:J);
    for s = 2:sims
        for j = zNoStars
            tmpnotj = notj(j,:);
            noStarIndx = zNoStars(j~= zNoStars);
            tsamp= [zs(1:rr), squeeze(rrs(s-1, 1, noStarIndx-1, rr))']';
            cmean = mu(j) - (1/H(j,j))*H(j,tmpnotj)*(tsamp - mu(tmpnotj)');
            rrs(s,2,j-1,rr) = cmean;
        end
    end
    if rr == nReducedRuns
        zs(rr+1:J) = squeeze(mean(rrs(burn+1:sims, 1, rr:J-1, rr)));
    else
        zs(rr+1:J) = mean(rrs(burn+1:sims, 1, rr:J-1, rr));
    end
end
rrs= rrs(burn+1:sims, :,:,:);
for i = 1:nReducedRuns
    fz(i+1) = mean( tnormpdf(a,b,rrs(:, 2, i, i),...
        rrs(:,3,i,i), zs(i+1)));
end
% Last run
HxxJ = conditionalVars(J);
HyxJ = H(J, notj(J,:));
sigmaxxJ = sqrt(HxxJ^(-1));
muJ = conditionalMeanMVN(mu(J), HxxJ, HyxJ, zs(1:J-1), mu(1:J-1));
fz(J) = tnormpdf(a,b, muJ, sigmaxxJ, zs(J));
end