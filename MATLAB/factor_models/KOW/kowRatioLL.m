function [Ans] = kowRatioLL(ydemut,ObsModel, ObsPriorMean, ObsPriorVar, Omega, factor,factorPrecision)
% A|f
sizeT = size(ydemut,2);
sizeA = size(ObsPriorVar,1);
speyet = speye(sizeT);
ObsPriorInv = ObsPriorVar\eye(sizeA);
OmegaInv = diag(Omega.^(-1));
f2Oi = (factor*factor').*OmegaInv;
Phi = (ObsPriorInv + f2Oi)\eye(sizeA);
phi = (Phi*(sum(factor.*(OmegaInv*ydemut),2) + ObsPriorInv*ObsPriorMean'))';
PartA = logmvnpdf(ObsModel',phi,Phi);
% f|A
AOi = ObsModel'*OmegaInv;
AOiA = AOi*ObsModel;
kAOiA = kron(speyet, AOiA);
Vprecision = factorPrecision + kAOiA;
Vvar = Vprecision\eye(size(Vprecision,1));
theta = kron(speyet,AOi)*ydemut(:);
fmean = Vvar*theta;
PartB = logmvnpdf(factor, fmean', Vvar);
Ans = PartA - PartB;
end

