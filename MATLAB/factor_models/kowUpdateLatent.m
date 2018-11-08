function [x, G] = kowUpdateLatent(vecresids, ObsModel, StatePrecision, ObsModelPrecision, T)

[Nobseqns, Nstates] = size(ObsModel);
Total = T*Nstates;
speyet = speye(T);
G = kron(speyet, ObsModel);
GtP = ObsModel'*spdiags(ObsModelPrecision,0, Nobseqns,Nobseqns);
KroneckerVariance = kron(speye(T),GtP*ObsModel);
L = StatePrecision + KroneckerVariance;
L = chol(L,'lower');
Li = L\speye(size(L,1));
ForwardSolved = Li*kron(speyet,GtP) *vecresids;

upperoff = triu(L',1);
diagelems = diag(L);
eta = zeros(Total,1);
eta(Total) = ForwardSolved(Total);
epsilon = normrnd(0,1,Total,1);
x = Li*epsilon;

for t = Total-1:(-1):1
   eta(t) = (ForwardSolved(t) - upperoff(t,:)*eta)/diagelems(t+1); 
end

x = (eta + x);
end

