function [x, G] = kowUpdateLatent(vecresids, ObsModel, StatePrecision, ObsModelVariances, T)



[Nobseqns, Nstates] = size(ObsModel);
Total = T*Nstates;
G = kron(speye(T), ObsModel);
KroneckerVariance = spdiags(repmat(1./ObsModelVariances, T*Nobseqns,1),0, T*Nobseqns, T*Nobseqns);
L = StatePrecision + G'*KroneckerVariance*G;
L = chol(L,'lower');
Li = L\speye(size(L,1));

ForwardSolved = Li*G'*KroneckerVariance*vecresids;

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

