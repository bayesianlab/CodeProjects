function [draw, P] = kowUpdateLatent(vecresids, ObsModel, StatePrecision, preom)
[nEqns] = size(ObsModel,1);
T = length(vecresids)/nEqns;
eyet = eye(T);
nFactors=size(ObsModel,2);
FullPrecision = diag(preom);
GtO = ObsModel'*FullPrecision;
P = StatePrecision + kron(eyet, GtO*ObsModel);
LP = chol(P,'lower');
LPi = LP\eye(size(P,1));
k=1:nEqns;
musum = zeros(nFactors,T);
for t = 1:T
    select = k + (t-1)*nEqns;
    musum(:,t)= GtO*vecresids(select);
end
mu = LPi'*LPi*musum(:);
u = normrnd(0,1,size(P,1),1);
x = LPi' * u;
draw = mu + x;
end


