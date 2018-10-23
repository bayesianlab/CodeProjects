function [ avgscore,avgHess ] = kowml(y, mu, sigmaVector,obsModel, S123)
% S is the precision, inverse of diagonals are conditional variances 

demeany = y-mu;
index =1:K;
setzero = zeros(K,1);
outerprod = zeros(Km1,Km1);
keepscore = zeros(Km1,T);
obsModel = [1;obsModel];

A = spdiags(Tvector.*CurrentObsModel(newS,1), 0, T,T);
B = spdiags(Tvector.*CurrentObsModel(newS,2), 0, T,T);
C = spdiags(Tvector.*CurrentObsModel(newS,3), 0, T, T);
for t = 1:T
%     Vtinv = woodburyInvert(sigmaVector, obsModel, Sdiag(t), obsModel');

    Vtinv = recursiveWoodbury(diag(ones(T,1).*...
        vectorObservationVariances(1)), A, S123(:,:,1,newS), B,...
        S123(:,:,2,newS),C, S123(:,:,3,newS)) ;

    for k = 1:K
        Sdiag = S123(:,:,k,?) 
        dela = setzero;
        dela(k) = 1;
        select = index + (t-1)*K;
        ystar = Vtinv*demeany(select);
        keepscore(k-1,t) = ystar'*(dela*Sdiag(t)*a'* ystar) -...
            trace(Vtinv*a*Sdiag(t)*dela');
    end
    outerprod = outerprod + keepscore(:,t)*keepscore(:,t)';
end
avgscore = sum(keepscore,2)./T;
avgHess = outerprod./T;
end


