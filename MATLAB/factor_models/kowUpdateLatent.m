function [x] = kowUpdateLatent(vecresids, StateVarMat, ObsModel, ObsModelVariances)
T = size(StateVarMat,1);
K = length(ObsModelVariances);

L = sparse(chol(StateVarMat, 'lower'));
U = L';
Li = L\eye(T);
G = sparse(kron(eye(T), ObsModel));
Omega = spdiags(repmat(ObsModelVariances,T,1), 0, T*K, T*K);
ForwardSolved = Li*G'*Omega*vecresids;
upperoff = triu(U,1);
eta = zeros(T,1);
eta(T) = ForwardSolved(T);
epsilon = normrnd(0,1,T,1);
x = Li*epsilon;
for t = T-1:(-1):1
   eta(t) = ForwardSolved(t) - upperoff(t,:)*eta; 
end
x = (eta + x)';
end

