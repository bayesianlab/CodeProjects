function [betabar, R0bar, acceptrate,sto] = mv_probit(y,X, b0, B0,...
    wishartDf, D0, R0, Sims)
% y is expected as [y11,..., y1T; 
%                   y21,...,y2T]
% Dimension sizes needed
% X is longitudnal binary
[r,c] = size(X);
[CorrelationMatrixDimension,~]= size(R0);
SubjectNumber = r/CorrelationMatrixDimension;
% Prior initialization
wprior = eye(CorrelationMatrixDimension);

W0 = (D0.^(.5))*R0*(D0.^(.5));
B=b0;
B0inv = inv(B0);
BpriorsPre = B0inv*b0;
z = y;
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
if isinteger(.1*Sims)
    burnin = floor(.1*Sims);
else
    burnin = 1;
end
for i = 1 : Sims
    mu = X*B;
    reshapedmu = reshape(mu, CorrelationMatrixDimension, SubjectNumber);
    z = updateLatentZ(y,reshapedmu, R0, z);
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
    
    [Wstar, Dstar, Rstar] = mhstep_mvprobit(wishartDf, W0./wishartDf);
    i
    W0
    Num = logpxWishart(Dstar,Rstar,wishartDf, wprior) + ...
          surLL(z',reshapedmu',Rstar) + ...
          logwish(W0, Wstar, wishartDf) ;
    Den = logpxWishart(D0,R0,wishartDf, wprior) + ...
          surLL(z',reshapedmu',R0) + ...
          logwish(Wstar, W0, wishartDf);
    alpha = min(0, Num - Den);
    if lu(i) < alpha
        accept = accept + 1;
        D0 = Dstar;
        R0 = Rstar;
        W0 = Wstar;
    end
    if i > burnin
       R0avg = R0avg + R0;
    end
end
R0bar= R0avg/(Sims-burnin + 1);
acceptrate = accept/Sims;
betabar = mean(stoB(burnin:end,:),1);
end