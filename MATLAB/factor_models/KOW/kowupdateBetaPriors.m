function [ b, demeanedyt ] = kowupdateBetaPriors(ys, SurX, obsModelPrecision, StateObsModel,...
    StatePrecision, T )

nEqns = length(obsModelPrecision);
nFactors = size(StateObsModel,2);
sizeStatePre = size(StatePrecision,1);
i = 1:nEqns;
j = 1:nFactors;
fullpre = spdiags(obsModelPrecision,0, nEqns, nEqns);
Inside = StatePrecision + kron(speye(T),...
    StateObsModel'* fullpre *StateObsModel);
% [L, p] = chol(Inside, 'lower');
% Li = L\eye(sizeStatePre);
% Pinverse = Li*Li';
% Pinverse = (StatePrecision + kron(speye(T),...
%     StateObsModel'* fullpre *StateObsModel))\speye(sizeStatePre);
Astar = StateObsModel'*fullpre;
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
    tmpxTimesPrecision = tmpx' * fullpre;
    addup = addup +  tmpxTimesPrecision* tmpx;
    sumup = sumup + tmpxTimesPrecision*tmpy;
    Xstar(pick, :) = Astar*tmpx;
    ystar(pick, :) = Astar*tmpy;
end
PinvXstar = (Inside\speye(size(Inside,1)))*Xstar;
VarTerm = (addup - (Xstar'*PinvXstar));
VarTerm = (eye(size(VarTerm,1)) + VarTerm);
NumeratorTerm = sumup - PinvXstar'*ystar;
[L,p] = chol(VarTerm,'lower');
p
if p ~= 0
    b = VarTerm\NumeratorTerm;
else
    b = linSysSolve(L, NumeratorTerm);
end
demeanedyt = reshape(ys - SurX*b, nEqns, T);
end
