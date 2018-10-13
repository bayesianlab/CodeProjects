function [ avgscore,avgHess ] = DmarginalLogLikelihood(y,mu,FullSigma,a, Sdiag )
% S is the precision, inverse of diagonals are conditional variances 
K = size(FullSigma,1);
Km1 = K-1;
T = length(y)/K;
demeany = y-mu;
index =1:K;
setzero = zeros(K,1);
outerprod = zeros(Km1,Km1);
keepscore = zeros(Km1,T);
a = [1;a];
for t = 1:T
    Vtinv = woodburyInvert(FullSigma, a, Sdiag(t), a');
    for k = 2:K
        dela = setzero;
        dela(k) = 1;
        select = index + (t-1)*K;
        ystar = Vtinv*demeany(select);
        SinvtaT = Sdiag(t) *a';
        middle = dela*SinvtaT;
        keepscore(k-1,t) = ystar'*(middle * ystar) -...
            trace(Vtinv*dela*SinvtaT);
    end
    outerprod = outerprod + keepscore(:,t)*keepscore(:,t)';
end
avgscore = sum(keepscore,2)./T;
avgHess = outerprod./T;
end

