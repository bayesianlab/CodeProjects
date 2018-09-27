function [betabar, R0bar, acceptrate, r0Elems, R0sto, stoB] = mv_probit(y,X, b0, B0,...
    wishartDf, D0, R0, Sims, r0indxs)
% y is expected as [y11,..., y1T; 
%                   y21,...,y2T]
% Dimension sizes needed
% X is longitudnal data
% subject Xij = [1, x(i,1,...J)]
if floor(.1*Sims) > 1
    burnin = floor(.1*Sims);
else
    burnin = 1;
end

[r,c] = size(X);
[CorrelationMatrixDimension,~]= size(R0);
SubjectNumber = r/CorrelationMatrixDimension;
% Prior initialization
wprior = eye(CorrelationMatrixDimension);
B=b0;
B0inv = inv(B0);
BpriorsPre = B0inv*b0;
R0avg = R0;
% Storage containers and intialize local vars. 
lu = log(unifrnd(0,1,Sims,1));
s1 = zeros(c,c);
s1eye = eye(c,c);
s2= zeros(c,1);
tempSum1 = s1;
tempSum2=s2;
accept = 0;
stoB = zeros(Sims, c);
trackingNum = size(r0indxs,1);
r0Elems = zeros(Sims-burnin, trackingNum);
postDraws = 0;
R0sto = zeros(CorrelationMatrixDimension, CorrelationMatrixDimension, Sims-burnin);
for i = 1 : Sims
    fprintf('%i\n',i)
    mu = X*B;
    reshapedmu = reshape(mu, CorrelationMatrixDimension, SubjectNumber);
    z = updateLatentZ(y,reshapedmu, R0);
    R0i = inv(R0);
    index =1:CorrelationMatrixDimension;
    for k = 1:SubjectNumber
        select = index + (k-1)*CorrelationMatrixDimension;
        tempSum1 = tempSum1 + X(select, :)'*R0i*X(select,:);
        tempSum2 = tempSum2 + X(select, :)'*R0i*z(:,k);
    end
    B0 = (B0inv + tempSum1)\s1eye;
    b0 = B0*(BpriorsPre + tempSum2);
    B = b0 + chol(B0,'lower')*normrnd(0,1,c,1);
    stoB(i,:) = B';
    tempSum1=s1;
    tempSum2=s2;
    % Correlation Matrix Part
    if i == 1
        demz = z-reshape(X*B, CorrelationMatrixDimension, SubjectNumber);
        W0 = demz*demz';
        D0 = diag(diag(W0));
        D0ihalf = diag(diag(D0).^(-.5));
        R0 = D0ihalf*W0*D0ihalf;
    end
    [Wstar, Dstar, Rstar] = proposalStepMvProbit(wishartDf,W0);
    alpha = mhStepMvProbit(Wstar,Dstar,Rstar,W0, D0, R0, wprior, ...
        wishartDf, z', reshapedmu');
    if lu(i) < alpha
        accept = accept + 1;
        D0 = Dstar;
        R0 = Rstar;
        W0 = Wstar;
    end
    if i > burnin
        postDraws = postDraws + 1;
        for k = 1:trackingNum
            r0Elems(postDraws,k) = R0(r0indxs(k,1), r0indxs(k,2));
        end
       R0avg = R0avg + R0;
       R0sto(:,:,postDraws) = R0;
    end

end
R0bar= R0avg/(Sims-burnin + 1);
acceptrate = accept/Sims;
betabar = mean(stoB(burnin:end,:),1);

end