function [ Kernel ] = askKernel( a,b, z, zStar, mu, sigma )
[r,~] = size(z);
[J,~] = size(sigma);
notj = notJindxs(J);
precision = inv(sigma);
condVars = diag(precision);
Hx1 = condVars(1);
Hy1 = precision(1, notj(1,:));
sigma11 = sqrt(1/Hx1);
mu1 = conditionalMeanMVN(mu(1), Hx1, Hy1, z(:,2:J), mu(notj(1,:)))';
Kernel(:,1) = tnormpdf(a,b, mu1, repmat(sigma11,r,1), zStar(1));
for j = 2:J-1
    znotj = [repmat(zStar(1:j-1),r,1), z(:,j+1:J)];
    munotj = mu(notj(j,:));
    Hzz = condVars(j);
    Hzy = precision(j,notj(j,:));
    sigmazz = sqrt(1/Hzz);
    muj = conditionalMeanMVN(mu(j), Hzz, Hzy, znotj, munotj)';
    Kernel(:,j) = tnormpdf(a,b,muj,repmat(sigmazz,r,1), zStar(j));
end
muJ = conditionalMeanMVN(mu(J), condVars(J), precision(J,notj(J,:)),...
    repmat(zStar(1:J-1),r,1), mu(notj(J,:)))';
sigmaJJ = sqrt(1/condVars(J));
Kernel(:,J) = tnormpdf(a,b,muJ, sigmaJJ, zStar(J));
end

