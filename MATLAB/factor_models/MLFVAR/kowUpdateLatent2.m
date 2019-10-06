function [draw, P] = kowUpdateLatent2(vecresids, ObsModel, StatePrecision, FullPrecision)
[Nobseqns] = size(ObsModel,1);
T = length(vecresids)/Nobseqns;
speyet = speye(T);
GtO = ObsModel'*FullPrecision;
P = StatePrecision + GtO*ObsModel;
P = P\speye(size(P,1));
mu = P*(GtO*vecresids);
draw = mvnrnd(mu',P);
end

