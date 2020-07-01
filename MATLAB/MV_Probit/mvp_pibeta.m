function [pb] = mvp_pibeta(betastar, zt, surX, Sigma0,subsetIndices, kronB0inv, kronB0invb0)
[K,T]=size(zt);
[~, KP] = size(surX);
IK = eye(K);
IKP= eye(KP);
Sigma0Inv = Sigma0\IK;
VarSum = zeros(KP);
MuSum = zeros(KP,1);
for t = 1:T
    VarSum= VarSum+surX(subsetIndices(:,t),:)'*Sigma0Inv*surX(subsetIndices(:,t),:);
    MuSum = MuSum + surX(subsetIndices(:,t),:)'*Sigma0Inv*zt(:,t);
end
Bhatinv = (kronB0inv + VarSum);
lowerBhat = chol(Bhatinv,'lower')\IKP;
Bhat = lowerBhat'*lowerBhat;
bhat = Bhat*(kronB0invb0 + MuSum);
pb = logmvnpdf(betastar', bhat', Bhat);
end