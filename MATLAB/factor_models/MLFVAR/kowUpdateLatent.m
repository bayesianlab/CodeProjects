function [draw, P] = kowUpdateLatent(vecresids, ObsModel, StatePrecision, preom)
[Nobseqns] = size(ObsModel,1);
T = length(vecresids)/Nobseqns;
speyet = eye(T);
FullPrecision = diag(preom);
GtO = ObsModel'*FullPrecision;
P = StatePrecision + kron(speyet, GtO*ObsModel);
LP = chol(P,'lower');
LPi = LP\eye(size(P,1));
mu = LPi'*LPi*(kron(speyet,GtO)*vecresids);
u = normrnd(0,1,size(P,1),1);
x = LPi' * u;
draw = mu + x;
end


