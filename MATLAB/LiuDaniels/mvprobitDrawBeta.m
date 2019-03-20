function [betaDraw] = mvprobitDrawBeta(ystar,X,R)
[K,T] = size(ystar);
dimX = size(X,2);
inverseR = R \ eye(K);
sigBeta = zeros(dimX,dimX);
sumBeta= zeros(dimX,1);
block = 1:K;
for t = 1:T
    xselect = block + (t-1)*K;
    sigBeta = sigBeta + (X(xselect,:)'*inverseR) * X(xselect,:);
    sumBeta = sumBeta + (X(xselect,:)'*inverseR) *ystar(:,t);
end
sigBeta = sigBeta \ eye(dimX);
mubeta = sigBeta*sumBeta;
betaDraw = mvnrnd(mubeta', sigBeta)';

end

