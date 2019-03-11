function [pdfval] = PropLike(ObsModel,ydemut,ObsPriorMean, ObsPriorPrecision, obsPrecision, factor,factorPrecision)

[nFactors, T ] = size(factor);
K = length(obsPrecision);
nFactorsT = nFactors*T;
nFactorsK = nFactors*K;
% A | F
ObsModelT =ObsModel';
OmegaI = diag(obsPrecision);
FtOF = kron(OmegaI, factor*factor');
Avariance = (ObsPriorPrecision + FtOF)\speye(nFactorsK, nFactorsK);
Term = ((factor*ydemut').*obsPrecision');
Amean = Avariance*(ObsPriorPrecision*ObsPriorMean' + Term(:));
pdfA = logmvnpdf(ObsModelT(:)', Amean', Avariance);
% F | A
AOI = ObsModel'*OmegaI;
Fvariance = (factorPrecision + kron(speye(T),AOI*ObsModel))\eye(nFactorsT);
Fmean = Fvariance*(kron(speye(T), AOI)*ydemut(:));
pdfF = logmvnpdf(factor(:)', Fmean', Fvariance);
pdfval = pdfA- pdfF;
end