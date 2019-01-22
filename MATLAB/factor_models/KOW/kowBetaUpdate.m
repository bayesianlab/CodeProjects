function [ b, ydemut, Precision ] = kowBetaUpdate(vecy, SurX,...
    obsModelPrecision, StateObsModel, StatePrecision, T )
%% Validated.
fprintf('\nBeginning beta update...\n')
nEqns = length(obsModelPrecision);
nFactors = size(StateObsModel,2);
i = 1:nEqns;
j = 1:nFactors;
fullpre = spdiags(obsModelPrecision,0, nEqns, nEqns);
Inside = StatePrecision + kron(speye(T),...
    StateObsModel'* fullpre *StateObsModel);

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
    tmpy = vecy(select);
    tmpxTimesPrecision = tmpx' * fullpre;
    addup = addup +  tmpxTimesPrecision* tmpx;
    sumup = sumup + tmpxTimesPrecision*tmpy;
    Xstar(pick, :) = Astar*tmpx;
    ystar(pick, :) = Astar*tmpy;
end
XstarPinv = Xstar'*(Inside\speye(size(Inside,1)));
Precision = speye(cx) + addup - (XstarPinv*Xstar);
NumeratorTerm = sumup - (XstarPinv*ystar);
Variance = Precision\speye(cx);
b = Variance*NumeratorTerm;
b = mvnrnd(b',Variance)';
ydemut = reshape(vecy - SurX*b, nEqns, T);
end
