function [ll] = kowLL(obsModelTransition, ydemu, StatePrecision, obsPrecision)
SPSize = size(StatePrecision,1);
K = length(obsPrecision);
R = size(ydemu,1);
T = R/K;
eyespsize = speye(SPSize);
eyet = speye(T);
O = diag(obsPrecision);
Oa = O*obsModelTransition;
kOa = kron(eyet, Oa);
Middle =(StatePrecision +  kron(eyet, obsModelTransition'*Oa)) \ eyespsize;
P = spdiags(repmat(obsPrecision, T,1),0,K*T, K*T) - kOa* Middle *kOa';
ll = kowOptimLogMvnPdf(ydemu, P);
end

