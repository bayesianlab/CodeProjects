function [pdfval] = AproptoLLLevel1(ObsModel,ydemut,...
    ObsPriorMean, ObsPriorPrecision, obsPrecision, factor,factorPrecision)
[nFactors, T ] = size(factor);
K = length(obsPrecision);
nFactorsT = nFactors*T;
nFactorsK = nFactors*K;
bottomDim = nFactors*(K-1);
topDim = nFactors-1;
% A | F
OmegaI = diag(obsPrecision);
OmegaIsub = diag(obsPrecision(2:K));
FtF = factor*factor';
Top = [FtF(1:nFactors-1, 1:nFactors-1)./obsPrecision(1), zeros(topDim, bottomDim)];
FtOF = [zeros(bottomDim, topDiim), kron(OmegaIsub, FtF)];
FtOF = [Top;FtOf];
yrestricted = ydemut(1,:) - factor(K,:);
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

