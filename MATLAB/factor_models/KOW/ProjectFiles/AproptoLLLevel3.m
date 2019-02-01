function [pdfval] = AproptoLLLevel3(ObsModel,ydemut,...
    ObsPriorMean, ObsPriorPrecision, obsPrecision, factor,factorPrecision)
[nFactors, T ] = size(factor);
K = length(obsPrecision);
nFactorsT = nFactors*T;
nFactorsK = nFactors*K;

% A | F
OmegaI = diag(obsPrecision);
OmegaIsub = diag(obsPrecision(2:K));
FtF = factor*factor';
FtOF = kron(OmegaIsub, FtF);
yrestricted = ydemut(1,:) - sum(factor(1:end,:),1);
Avariance = (obsPrecision + FtOF)\speye(nFactorsK, nFactorsK);
Term = ((factor*yrestricted')./obsPrecision');
Amean = AFvariance*(ObsPriorPrecision*ObsPriorMean' + Term(:));
pdfA = logmvnpdf(ObsModel, Amean, Avariance);

% F | A
AOI = ObsModel'*OmegaI;
Fvariance = (factorPrecision + AOI*ObsModel)\eye(nFactorsT);
Fmean = Fvariance*(kron(speye(T), AOI)*ydemut(:));
pdfF = logmvnpdf(factor(:)', Fmean', Fvariance);
pdfval = pdfA- pdfF;
end

