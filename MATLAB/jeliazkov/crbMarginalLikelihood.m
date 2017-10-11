function [zStar, fzStar] = crbMarginalLikelihood(a,b,mu, precision, X,sims, burn)
% X is the main run results, stored X(dim1->sims, dim2->[sims, mu,sigma], dim3->variable) 
[~,~,J] = size(X);
zStar = zeros(1,J);
means = reshape(mean(X(:, 1, :)), [1,J]);
zStar(1) = means(1);
nReducedRuns = J-2;
redRunSample = zeros(sims, 3, J-1, nReducedRuns);

fzStar = zeros(1,J);
conditionalVars = diag(precision);
notJIndices = notJindxs(J);
fzStar(1) = mean(tnormpdf(a,b,X(:,2,1), X(:,3,1),zStar(1)));
% No point in first dimension in redRunSample because 
% zstar 1 is already calc.ed.
for rr = 1:nReducedRuns
    zNoStars = rr+1:J;
    for s = 2:sims
        for j = zNoStars
            noStarIndx = zNoStars(j~= zNoStars);
            xNotj = [zStar(1:rr), squeeze(redRunSample(s-1, 1, noStarIndx-1, rr))'];
            muNotj = mu(notJIndices(j,:));
            Hxx = conditionalVars(j);
            Hyx = precision(j, notJIndices(j,:));
            sigmaxx = sqrt(Hxx^(-1));
            muj = conditionalMeanMVN(mu(j), Hxx,Hyx,xNotj,muNotj);
            redRunSample(s, :, j-1, rr) = [tnormrnd(a,b,muj,sigmaxx), muj, sigmaxx];
        end
    end
    if rr == nReducedRuns
        zStar(rr+1:J) = squeeze(mean(redRunSample(burn+1:sims, 1, rr:J-1, rr)));
    else
        zStar(rr+1) = mean(redRunSample(burn+1:sims, 1, rr, rr));
    end
end
redRunSample = redRunSample(burn+1:sims, :,:,:);
for i = 1:nReducedRuns
    fzStar(i+1) = mean( tnormpdf(a,b,redRunSample(:, 2, i, i),...
        redRunSample(:,3,i,i), zStar(i+1)));
end
% Last run
HxxJ = conditionalVars(J);
HyxJ = precision(J, notJIndices(J,:));
sigmaxxJ = sqrt(HxxJ^(-1));
muJ = conditionalMeanMVN(mu(J), HxxJ, HyxJ, zStar(1:J-1), mu(1:J-1));
fzStar(J) = tnormpdf(a,b, muJ, sigmaxxJ, zStar(J));
end
