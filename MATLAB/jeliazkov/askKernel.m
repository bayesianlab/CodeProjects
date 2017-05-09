function [ Kernel ] = askKernel( a,b, z, zStar, mu, sigma )
[r,~] = size(z);
[J,~] = size(sigma);
notj = notJindxs(J);

precision = inv(sigma);
condVars = diag(precision);
mu1 = conditionalMeanMVN(mu(1), condVars(1), precision(1,notj(1,:)),...
    z(:,2:J), mu(notj(1,:)))';
sig1 = sqrt(1/condVars(1));
Kernel(:,1) = tnormpdf(a,b, mu1, repmat(sig1,r,1), zStar(1));
for j = 2:J-1
    znotj = [repmat(zStar(1:j-1),r,1), z(:,j+1:J)];
    munotj = mu(notj(j,:));
    Hxx = condVars(j);
    Hyx = precision(j,notj(j,:));
    sigmazz = sqrt(1/Hxx);
    muj = conditionalMeanMVN(mu(j), Hxx, Hyx, znotj, munotj)';
    Kernel(:,j) = tnormpdf(a,b,muj,repmat(sigmazz,r,1), zStar(j));
end
muJ = conditionalMeanMVN(mu(J), condVars(J), precision(J,notj(J,:)),...
    repmat(zStar(1:J-1),r,1), mu(notj(J,:)))';
Kernel(:,J) = tnormpdf(a,b,muJ, sqrt(1/condVars(J)), zStar(J));
end

