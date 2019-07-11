function [pdfval] = spatial_Amll(ObsModel,  ydemut,...
    ObsPriorMean, ObsPriorPrecision, ObsPrecision, factor,...
    factorPrecision)
vecObsModel = ObsModel(:);
[nFactors, T ] = size(factor);
K = size(ObsPrecision,1);
nFactorsT = nFactors*T;
nFactorsK = nFactors*K;
% A | F
FtOF = kron(ObsPrecision, factor*factor');
Avariance = (ObsPriorPrecision + FtOF)\speye(nFactorsK, nFactorsK);
Term = kron(eye(K), factor')' * kron(eye(T), ObsPrecision) * ydemut(:);
Amean = Avariance*(ObsPriorPrecision*ObsPriorMean' + Term(:));
pdfA = logmvnpdf(vecObsModel', Amean', Avariance);

% F | A
AOI = ObsModel'*ObsPrecision;
Fvariance = (factorPrecision + kron(speye(T),AOI*ObsModel))\eye(nFactorsT);
Fmean = Fvariance*(kron(speye(T), AOI)*ydemut(:));
pdfF = logmvnpdf(factor(:)', Fmean', Fvariance);
pdfval = pdfA- pdfF;
end

