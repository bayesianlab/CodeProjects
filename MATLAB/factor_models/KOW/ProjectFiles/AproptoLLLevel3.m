function [pdfval] = AproptoLLLevel3(ObsModel,ydemut,...
    ObsPriorMean, ObsPriorPrecision, obsPrecision, factor,factorPrecision)
[nFactors, T ] = size(factor);
K = length(obsPrecision);
nFactorsT = nFactors*T;
nFactorsK = nFactors*K;
dimension = nFactors*(K-1);
speyet = speye(T);
% A | F
obsRestricted = obsPrecision(2:K);
OmegaI = diag(obsPrecision);
OmegaIsub = diag(obsRestricted);
FtF = factor*factor';
FtOF = kron(OmegaIsub, FtF);
yrestricted = ydemut(2:K, :);
Avariance = (ObsPriorPrecision + FtOF)\speye(dimension, dimension);
Term = ((factor*yrestricted')./obsRestricted');
Amean = Avariance*(ObsPriorPrecision*ObsPriorMean' + Term(:));
pdfA = logmvnpdf(ObsModel(2:end)', Amean', Avariance);

% F | A
A = [ones(1,nFactors);ObsModel(2:end)];
AOI = A'*OmegaI;
Fvariance = (factorPrecision + kron(speyet,AOI*A))\eye(nFactorsT);
Fmean = Fvariance*(kron(speyet, AOI)*ydemut(:));
pdfF = logmvnpdf(factor(:)', Fmean', Fvariance);
pdfval = pdfA- pdfF;
end

