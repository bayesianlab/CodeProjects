function [ll] = kowLL(obsModelTransition, ydemu, StatePrecision, obsPrecision)
SPSize = size(StatePrecision,1);
K = length(obsPrecision);
R = size(ydemu,1);
T = R/K;
eyespsize = speye(SPSize);
eyet = speye(T);
Oi = diag(obsPrecision);
OiA = Oi*obsModelTransition;
Middle = (StatePrecision + kron(eyet, obsModelTransition'*OiA))\eyespsize;
P = kron(eyet, Oi) - (kron(eyet,OiA)*Middle*kron(eyet,OiA'));
ll = kowOptimLogMvnPdf(ydemu, P);
end

