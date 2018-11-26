function [draw] = kowUpdateLatent(vecresids, ObsModel, StatePrecision, ObsModelPrecision)

[Nobseqns] = size(ObsModel,1);
T = length(vecresids)/Nobseqns;
speyet = speye(T);
GtP = ObsModel'*spdiags(ObsModelPrecision,0, Nobseqns,Nobseqns);
KroneckerVariance = kron(speye(T),GtP*ObsModel);
x = kron(speyet,GtP) *vecresids;

P= StatePrecision + KroneckerVariance;
[mu, diagP, offdiagP] = solveSystem(P, x);
draw  = mvnrndPrecision(diagP, offdiagP) + mu;
end

