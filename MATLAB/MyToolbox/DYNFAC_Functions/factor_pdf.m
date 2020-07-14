function [pival] = factor_pdf(q, vecresids, ObsModel, StatePrecision, preom)
[nEqns] = size(ObsModel,1);
T = length(vecresids)/nEqns;
eyet = eye(T);
FullPrecision = diag(preom);
GtO = ObsModel'*FullPrecision;
P = StatePrecision + kron(eyet, GtO*ObsModel);
LP = chol(P,'lower');
LPi = LP\eye(size(P,1));
musum=GtO*reshape(vecresids,nEqns,T);
V = (LPi'*LPi);
mu = V*musum(:);
pival=logmvnpdf(q, mu', V);
end

