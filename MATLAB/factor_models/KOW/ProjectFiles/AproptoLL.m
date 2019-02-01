function [pdfval] = AproptoLL(ObsModel,ydemut,ObsPriorMean, ObsPriorPrecision, obsPrecision, factor,factorPrecision)

[nFactors, T ] = size(factor);
K = length(obsPrecision);
nFactorsT = nFactors*T;
nFactorsK = nFactors*K;
% A | F
OmegaI = diag(obsPrecision);
FtOF = kron(OmegaI, factor*factor');
Avariance = (obsPrecision + FtOF)\speye(nFactorsK, nFactorsK);
Term = ((factor*ydemut')./obsPrecision');
Amean = AFvariance*(ObsPriorPrecision*ObsPriorMean' + Term(:));
pdfA = logmvnpdf(ObsModel, Amean, Avariance);

% F | A
AOI = ObsModel'*OmegaI;
Fvariance = (factorPrecision + AOI*ObsModel)\eye(nFactorsT);
Fmean = Fvariance*(kron(speye(T), AOI)*ydemut(:));
pdfF = logmvnpdf(factor(:)', Fmean', Fvariance);
pdfval = pdfA- pdfF;
end

