function [ b ] = kowupdateBetaPriors(ys, SurX, Precision, StateObsModel,...
    StatePrecision, nEqns, nFactors, T )...


i = 1:nEqns;
j = 1:nFactors;
Pinverse = (StatePrecision + kron(speye(T),...
    StateObsModel'*StateObsModel))\speye(size(StatePrecision,1));
Astar = StateObsModel'*Precision;
cx = size(SurX,2);
addup = zeros(cx,cx);
sumup = zeros(cx,1);
Xstar = zeros(nFactors*T, cx);
ystar = zeros(nFactors*T,1);
for t = 1:T
    select = i + (t-1)*nEqns;
    pick = j + (t-1)*nFactors;
    tmpx = SurX(select,:);
    tmpy = ys(select);
    tmpxTimesPrecision = tmpx' * Precision;
    addup = addup +  tmpxTimesPrecision* tmpx;
    sumup = sumup + tmpxTimesPrecision*tmpy;
    Xstar(pick, :) = Astar*tmpx;
    ystar(pick, :) = Astar*tmpy;
end
xstarTimesP = Xstar'*Pinverse;
b = (addup - (xstarTimesP*Xstar))\(sumup - xstarTimesP*ystar);
end
