function [ avgscore,avgHess ] = DmarginalLogLikelihood(y,mu,...
    FullSigma,a, Sdiag )
% S is the precision, inverse of diagonals are conditional variances 
K = size(FullSigma,1);
Km1 = K-1;
T = length(y)/K;
demeany = y-mu;
index =1:K;
setzero = zeros(K,1);
SetZero = zeros(K,K);
outerprod = zeros(Km1,Km1);
keepscore = zeros(Km1,T);
a = [1;a];
notk = notJindxs(K);

for t = 1:T
    Vtinv = woodburyInvert(FullSigma, a, Sdiag(t), a');
    for k = 2:K
%         Dy = SetZero;
%         Dy(:, k) = a;
%         Dy(k, notk(k, :)) = a(notk(k,:));
%         Dy(k,k) = 2*Dy(k,k);
%         Dy = Sdiag(t).*Dy;
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

