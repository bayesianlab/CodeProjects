function [Ans] = kowRatioLL(ydemut,ObsModel, ObsPriorMean, ObsPriorVar, Omega, factor,factorPrecision)
% A|f
sizeT = size(ydemut,2);
sizeA = size(ObsPriorVar,1);
speyet = speye(sizeT);
ObsPriorInv = ObsPriorVar\eye(sizeA);
OmegaInv = diag(Omega.^(-1));
f2Oi = (factor*factor').*OmegaInv;
Phi = (ObsPriorInv + f2Oi)\eye(sizeA);
phi = Phi*(ObsPriorInv*ObsPriorMean' + sum(factor.*(OmegaInv*ydemut),2));
PartA = logmvnpdf(ObsModel',phi',Phi);
% f|A
AOi = ObsModel'*OmegaInv;
AOiA = AOi*ObsModel;
kAOiA = kron(speyet, AOiA);
Vprecision = factorPrecision + kAOiA;
Vvar = Vprecision\eye(size(Vprecision,1));
fmean = Vvar*(AOi*ydemut)';
PartB = logmvnpdf(factor, fmean', Vvar);
Ans = -(PartA - PartB);
end

