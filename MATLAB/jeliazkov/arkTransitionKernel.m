function [ Kernel ] = arkTransitionKernel(a,b,zStar, X, mu, precision, conditionalVars)
[r,~,J] = size(X);
Kernel = zeros(r, J);
notj = notJindxs(J);
Kernel(:,1) = tnormpdf(a,b,X(:,2,1), X(:,3,1),zStar(1));
for j = 2:J-1
     xNotj = [repmat(zStar(1:j-1),r,1), squeeze(X(:, 1, j+1:J))];
     muNotj = mu(notj(j,:));
     Hxx = conditionalVars(j);
     Hyx = precision(j, notj(j,:));
     sigmaxx = sqrt(1/Hxx);
     muj = conditionalMeanMVN(mu(j), Hxx, Hyx, xNotj, muNotj)';
     Kernel(:,j) = tnormpdf(a,b, muj, repmat(sigmaxx, r,1), zStar(j));
end
HxxJ = conditionalVars(J);
HyxJ = precision(J, notj(J,:));
sigmaxxJ = sqrt(1/HxxJ);
muJ = conditionalMeanMVN(mu(J), HxxJ, HyxJ, repmat(zStar(1:J-1), r,1), mu(notj(J,:)))';
Kernel(:, J) = tnormpdf(a,b,muJ, repmat(sigmaxxJ,r,1), zStar(J));
end


