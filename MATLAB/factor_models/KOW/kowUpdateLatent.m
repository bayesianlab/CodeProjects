function [draw, P] = kowUpdateLatent(vecresids, ObsModel, StatePrecision, ObsModelPrecision)
[Nobseqns] = size(ObsModel,1);
T = length(vecresids)/Nobseqns;
speyet = speye(T);
FullPrecision = diag(ObsModelPrecision);
GtO = ObsModel'*FullPrecision;
P = StatePrecision + kron(speyet, GtO*ObsModel);
x = kron(speyet,GtO)*vecresids;
[mu, diagP, offdiagP] = solveSystem(P, x);
draw  = mvnrndPrecision(mu, diagP, offdiagP);
end

