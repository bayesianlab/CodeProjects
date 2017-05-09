function [ Kernel ] = sternKernel( a, b, u1MeanVar, zStar, randDraws,...
    mu, precision, conditionalVars)
[r,J] = size(randDraws);
Kernel = zeros(r, J);
notj = notJindxs(J);
Kernel(:,1) = tnormpdf(a,b,u1MeanVar(:,1), u1MeanVar(:,2),zStar(1));
for j = 2:J-1
     xNotj = [repmat(zStar(1:j-1),r,1), randDraws(:, j+1:J)];
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

