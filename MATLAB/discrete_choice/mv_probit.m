function [betabar, R0bar, acceptrate] = mv_probit(y,surX, b0, B0,...
    wishartDf, D0, R0, Sims, wishartproposal)
% y is expected as [y11,..., y1T; 
%                   y21,...,y2T]
% Dimension sizes needed
[r,c] = size(surX);
[neqns,~]= size(R0);
N = r/neqns;
% Prior initialization
W0 = D0*R0*D0;
B=b0;
B0inv = inv(B0);
BpriorsPre = B0inv*b0;
Sinv = inv(W0);
z = double(y);
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
for i = 1 : Sims
    mu = surX*B;
    reshapedmu = reshape(mu, neqns,N);
    z = updateLatentZ(y',reshapedmu', R0, z)';
    R0i = inv(R0);
    t=1;
    
    for k = 1:N
        tend = t + neqns - 1;
        tempSum1 = tempSum1 + surX(t:tend, :)'*R0i*surX(t:tend,:);
        tempSum2 = tempSum2 + surX(t:tend, :)'*R0i*z(:,k);
        t = tend + 1;
    end
    B0 = inv(B0inv + tempSum1);
    b0 = B0*BpriorsPre +  (B0 * tempSum2);
    B = b0 + chol(B0,'lower')*normrnd(0,1,c,1);
    stoB(i,:) = B';
    tempSum1=s1;
    tempSum2=s2;
    
    [W, D, R] = mhstep_mvprobit(wishartDf, wishartproposal);
    if det(D) > 1e2
        fprintf('Reset\n')
        W0 = eye(neqns);
        D0= .1*W0;
        R0 = W0;
    else
        Num = logpxWishart(D,R,wishartDf,W0) + ...
             surLL(z,reshapedmu,R) + ...
            logWishart(W0, wishartproposal, wishartDf);
        Den = logpxWishart(D0,R0,wishartDf,W) + ...
            surLL(z,reshapedmu,R0) + ...
            logWishart(W, wishartproposal, wishartDf);
        alpha = min(0, Num - Den);
        if lu(i) < alpha
            accept = accept + 1;
            D0 = D;
            R0 = R;
            W0 = W;
        end
    end
    if i > burnin
       R0avg = R0avg + R0;
    end
    
end
R0bar= R0avg/(Sims-burnin + 1);
acceptrate = accept/Sims;
betabar = mean(stoB(burnin:end,:),1);
end