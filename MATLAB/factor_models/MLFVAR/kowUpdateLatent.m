function [draw, P] = kowUpdateLatent(vecresids, ObsModel, StatePrecision, preom)
[nEqns] = size(ObsModel,1);
T = length(vecresids)/nEqns;
eyet = eye(T);
FullPrecision = diag(preom);
GtO = ObsModel'*FullPrecision;
P = StatePrecision + kron(eyet, GtO*ObsModel);
LP = chol(P,'lower');
LPi = LP\eye(size(P,1));
musum=GtO*reshape(vecresids,nEqns,T);
mu = (LPi'*LPi)*musum(:);
u = normrnd(0,1,size(P,1),1);
x = LPi' * u;
draw = mu + x;
end


