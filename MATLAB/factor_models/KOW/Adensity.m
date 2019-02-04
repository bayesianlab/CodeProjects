function [ pdfval ] = Adensity( ObsModel,ydemut,...
    ObsPriorMean, ObsPriorPrecision, obsPrecision, factor,factorPrecision)
[nFactors, T ] = size(factor);
K = length(obsPrecision);
nFactorsT = nFactors*T;
nFactorsK = nFactors*K;
dimension = nFactors*(K-1);
speyet = speye(T);
% A | F

OmegaI = diag(obsPrecision);

FtF = factor*factor';
FtOF = kron(OmegaIsub, FtF);

Avariance = (ObsPriorPrecision + FtOF)\speye(dimension, dimension);
Term = ((factor*yrestricted')./obsRestricted');
Amean = Avariance*(ObsPriorPrecision*ObsPriorMean' + Term(:));

pdfA = logmvnpdf(ObsModel', Amean', Avariance);

% F | A

A = reshape(ObsModel, K-1, nFactors);
A = [ones(1,nFactors);A];
AOI = A'*OmegaI;
Fvariance = (factorPrecision + kron(speyet,AOI*A))\eye(nFactorsT);
Fmean = Fvariance*(kron(speyet, AOI)*ydemut(:));
pdfF = logmvnpdf(factor(:)', Fmean', Fvariance);
pdfval = pdfA- pdfF;


end

