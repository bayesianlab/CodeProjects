function [ avgscore,avgHess ] = kowml(demeanedy, sigmaVector, ObsModel,...
    Sworld, Sregion, Scountry)
% S is the precision, inverse of diagonals are conditional variances 

setzero = zeros(K,1);
outerprod = zeros(Km1,Km1);
keepscore = zeros(Km1,T);

for t = 1:T
    Vtinv = recursiveWoodbury(sigmaVector(t), ObsModel(1), Sworld(t), ObsModel(2),...
        Sregion(t,t,region), ObsModel(3), Scountry(t,t,country));
    for k = 1:3
        if k == 1
            Sdiag = diag(Sworld);
            a = ObsModel(1);
        elseif k == 2
            Sdiag = daig(Sregion);
            a = ObsModel(2);
        else
            Sdiag = diag(Scountry);
            a = ObsModel(3);
        end
        dela = setzero;
        dela(k) = 1;
        ystar = Vtinv*demeanedy(t);
        keepscore(k,t) = ystar'*(dela*Sdiag(t)*a'* ystar) -...
            trace(Vtinv*a*Sdiag(t)*dela');
    end
    outerprod = outerprod + keepscore(:,t)*keepscore(:,t)';
end
avgscore = sum(keepscore,2)./T;
avgHess = outerprod./T;

end


