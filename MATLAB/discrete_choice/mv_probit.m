function [betabar, R0bar, acceptrate, r0Elems, R0sto, stoB] = mv_probit(y,X, b0, B0,...
    wishartDf, D0, R0, Sims, burnin, r0indxs)
% y is expected as [y11,..., y1T; 
%                   y21,...,y2T]
% Dimension sizes needed
% X is longitudnal data
% subject Xij = [1, x(i,1,...J)]

[r,c] = size(X);
[K,~]= size(R0);
SampleSize = r/K;
% Prior initialization
wprior = eye(K).*100;
% eye(CorrelationMatrixDimension);
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
W0= D0*R0*D0;
R0sto = zeros(K, K, Sims-burnin);
for i = 1 : Sims
    fprintf('%i\n',i)
    mu = X*B;
    reshapedmu = reshape(mu, K, SampleSize);   
    z = updateLatentZ(y,reshapedmu, R0);
    R0i = inv(R0);
    index =1:K;
    for k = 1:SampleSize
        select = index + (k-1)*K;
        tempSum1 = tempSum1 + X(select, :)'*R0i*X(select,:);
        tempSum2 = tempSum2 + X(select, :)'*R0i*z(:,k);
    end
    B0 = (B0inv + tempSum1)\s1eye;
    b0 = B0*(BpriorsPre + tempSum2);
    B = b0 + chol(B0,'lower')*normrnd(0,1,c,1);
    stoB(i,:) = B;
    tempSum1=s1;
    tempSum2=s2;
    % Correlation Matrix Part

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
betabar = mean(stoB(burnin+1:end,:),1);

end