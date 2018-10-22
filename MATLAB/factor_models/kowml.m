function [ avgscore,avgHess ] = kowml(y,mu,...
    sigmaVector,obsModel, Sdiag )
% S is the precision, inverse of diagonals are conditional variances 

demeany = y-mu;
index =1:K;
setzero = zeros(K,1);
outerprod = zeros(Km1,Km1);
keepscore = zeros(Km1,T);
obsModel = [1;obsModel];
for t = 1:T
    Vtinv = woodburyInvert(sigmaVector, obsModel, Sdiag(t), obsModel');
    for k = 2:K
        dela = setzero;
        dela(k) = 1;
        select = index + (t-1)*K;
        ystar = Vtinv*demeany(select);
        SinvtaT = Sdiag(t) *obsModel';
        middle = dela*SinvtaT;
        keepscore(k-1,t) = ystar'*(middle * ystar) -...
            trace(Vtinv*dela*SinvtaT);
    end
    outerprod = outerprod + keepscore(:,t)*keepscore(:,t)';
end
avgscore = sum(keepscore,2)./T;
avgHess = outerprod./T;
end


