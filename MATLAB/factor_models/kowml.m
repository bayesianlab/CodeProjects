function [ avgscore,avgHess ] = kowml(demeanedy, sigmaVector, ObsModel,...
    Sworld, Sregion, Scountry)
% S is the precision, inverse of diagonals are conditional variances 
K = 3;
T = size(demeanedy,1);
setzero = zeros(K,1);
outerprod = zeros(K,K);
keepscore = zeros(K,T);

for t = 1:T
    Vtinv = recursiveWoodbury(sigmaVector(t), ObsModel(1), Sworld(t), ObsModel(2),...
        Sregion(t,t), ObsModel(3), Scountry(t,t));
    for k = 1:3
        if k == 1
            Sdiag = diag(Sworld);
            a = ObsModel(1);
        elseif k == 2
            Sdiag = diag(Sregion);
            a = ObsModel(2);
        else
            Sdiag = diag(Scountry);
            a = ObsModel(3);
        end
        ystar = Vtinv*demeanedy(t);
        keepscore(k,t) = (ystar'*Sdiag(t))* (a'* ystar) -...
            trace(Vtinv*a*Sdiag(t));
    end
    outerprod = outerprod + keepscore(:,t)*keepscore(:,t)';
end

avgscore = mean(keepscore,2);
avgHess = outerprod./T;

end


