function [ Kernel ] = askTransitionKernel(etaStar, X, mu, iden, conditionalVars)
[r,~,J] = size(X);
Kernel = zeros(r, J);
notj = notJindxs(J);
Kernel(:,1) = tnormpdf(X(:,2,1),X(:,3,1), X(:,4,1), X(:,5,1), etaStar(1));
for j = 2:J-1
     etaNotj = [repmat(etaStar(1:j-1),r,1), squeeze(X(:, 1, j+1:J))];
     muNotj = mu(notj(j,:));
     Hxx = conditionalVars(j);
     Hyx = iden(j, notj(j,:));
     sigmaxx = sqrt(1/Hxx);
     muj = conditionalMeanMVN(mu(j), Hxx, Hyx, etaNotj, muNotj)';
     Kernel(:,j) = tnormpdf(X(:,2,j),X(:,3,j), muj, repmat(sigmaxx, r,1), etaStar(j));
end
HxxJ = conditionalVars(J);
HyxJ = iden(J, notj(J,:));
sigmaxxJ = sqrt(1/HxxJ);
muJ = conditionalMeanMVN(mu(J), HxxJ, HyxJ, repmat(etaStar(1:J-1), r,1), mu(notj(J,:)))';
Kernel(:, J) = tnormpdf(X(:,2,J),X(:,3,J),muJ, repmat(sigmaxxJ,r,1), etaStar(J));
end

