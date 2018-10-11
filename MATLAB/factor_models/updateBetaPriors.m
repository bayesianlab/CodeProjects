function [b,B  ] = updateBetaPriors(y,X,a, sigma2,F0, SigmaDiag ,b0, B0inv)
[rowsX, colsX] = size(X);
K = length(SigmaDiag);
T = rowsX/K;
Xhat = zeros(T, colsX);
yhat = zeros(T, 1);
diagSigmai = diag(SigmaDiag.^(-1));
aSigmai = a'*diagSigmai;

Pinv = (((1/sigma2)*F0) + diag(a'*(diagSigmai*a).*ones(T,1)))\eye(T);
index =1:K;
xpxsum = zeros(colsX,colsX);
xpysum = zeros(colsX,1);
for t = 1:T
    select = index + (t-1)*K;
    Xhat(t,:) = aSigmai*X(select,:);
    yhat(t, :) = (aSigmai*y(select,1))';
    xpysum = xpysum + X(select,:)'*diagSigmai*y(select);
    xpxsum = xpxsum + X(select,:)'*diagSigmai*X(select,:);
end

B = (B0inv + xpxsum - Xhat'*Pinv*Xhat)\eye(colsX) ;
b= B*(b0 + xpysum - Xhat'*Pinv*yhat) ;
end
