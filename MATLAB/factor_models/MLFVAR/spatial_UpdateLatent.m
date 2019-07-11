function [draw, P] = spatial_UpdateLatent(vecresids, ObsModel, StatePrecision, FullPrecision)
[Nobseqns] = size(ObsModel,1);
T = length(vecresids)/Nobseqns;
speyet = speye(T);
GtO = ObsModel'*FullPrecision;
P = StatePrecision + kron(speyet, GtO*ObsModel);
P = P\speye(size(P,1));
mu = P*(kron(speyet,GtO)*vecresids);
draw = mvnrnd(mu',P);
end

