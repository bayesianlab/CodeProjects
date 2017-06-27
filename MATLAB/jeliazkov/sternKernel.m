function [ Kernel ] = sternKernel( a, b, u1MeanVar, uStar, u,...
    mu, precision, conditionalVars)
[r,J] = size(u);
Kernel = zeros(r, J);
notj = notJindxs(J);
Kernel(:,1) = tnormpdf(a,b,u1MeanVar(:,1), u1MeanVar(:,2),uStar(1));
for j = 2:J-1
     uNotj = [repmat(uStar(1:j-1),r,1), u(:, j+1:J)];
     muNotj = mu(notj(j,:));
     Hxx = conditionalVars(j);
     Hyx = precision(j, notj(j,:));
     sigmaxx = sqrt(1/Hxx);
     muj = conditionalMeanMVN(mu(j), Hxx, Hyx, uNotj, muNotj)';
     Kernel(:,j) = tnormpdf(a,b, muj, repmat(sigmaxx, r,1), uStar(j));
end
HxxJ = conditionalVars(J);
HyxJ = precision(J, notj(J,:));
sigmaxxJ = sqrt(1/HxxJ);
muJ = conditionalMeanMVN(mu(J), HxxJ, HyxJ, repmat(uStar(1:J-1), r,1), mu(notj(J,:)))';
Kernel(:, J) = tnormpdf(a,b,muJ, repmat(sigmaxxJ,r,1), uStar(J));
end

