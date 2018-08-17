function [betabar, R0bar, acceptrate] = mv_probit(y,surX, b0, B0,...
    wishartDf, wishartPrior, D0, R0, Sims)
% y is expected as [y11,..., y1T; 
%                   y21,...,y2T]
% Dimension sizes needed
[r,c] = size(surX);
[CorrelationMatrixDimension,~]= size(R0);
SubjectNumber = r/CorrelationMatrixDimension;
% Prior initialization
W0 = (D0.^.5)*R0*(D0.^.5);
B=b0;
B0inv = inv(B0);
BpriorsPre = B0inv*b0;
Sinv = inv(W0);
z = y;
R0avg = R0;
% Storage containers and intialize local vars. 
lu = log(unifrnd(0,1,Sims,1));
s1 = zeros(c,c);
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
R0 = correlation([.9,.7,.5,.3]);
for i = 1 : Sims
    mu = surX*B;
    reshapedmu = reshape(mu, CorrelationMatrixDimension, SubjectNumber);
    z = updateLatentZ(y,reshapedmu, R0, z);
    R0i = inv(R0);
    select=1:CorrelationMatrixDimension;
    for k = 1:SubjectNumber
        tempSum1 = tempSum1 + surX(select, :)'*R0i*surX(select,:);
        tempSum2 = tempSum2 + surX(select, :)'*R0i*z(:,k);
    end
    [y;z]
    inv(tempSum1)*tempSum2;
    B0 = inv(B0inv + tempSum1);
    b0 = B0*(BpriorsPre + tempSum2);
    B = b0 + chol(inv(B0),'lower')*normrnd(0,1,c,1);
    stoB(i,:) = B';
    tempSum1=s1;
    tempSum2=s2;
    % Correlation Matrix Part
%     [W, D, R] = mhstep_mvprobit(wishartDf, W0);
%     if det(D) > 1e2
%         fprintf('Reset\n')
%         W0 = eye(CorrelationMatrixDimension);
%         D0= .1*W0;
%         R0 = W0;
%     else
%         Num = logpxWishart(D,R,wishartDf, wishartPrior) + ...
%               surLL(z,reshapedmu,R) + ...
%               logWishart(W0, W, wishartDf) ;
%         Den = logpxWishart(D0,R0,wishartDf, wishartPrior) + ...
%               surLL(z,reshapedmu,R0) + ...
%               logWishart(W, W0, wishartDf);
%         alpha = min(0, Num - Den);
%         if lu(i) < alpha
%             accept = accept + 1;
%             D0 = D;
%             R0 = R;
%             W0 = W;
%         end
%     end
%     if i > burnin
%        R0avg = R0avg + R0;
%     end
end
R0bar= R0avg/(Sims-burnin + 1);
acceptrate = accept/Sims;
betabar = mean(stoB(burnin:end,:),1);
end