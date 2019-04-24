function [pdfval] = spatial_LLRestrict(ObsModel,ydemut,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, factor,factorPrecision)
% One factor at a time
[nFactors, T ] = size(factor);
K = size(obsPrecision,1);
nFactorsT = nFactors*T;
nFactorsK = nFactors*K;
allBut1 = 2:K;
smallPrecision = obsPrecision(allBut1, allBut1);
% A | F
FtOF = kron(smallPrecision, factor*factor');
Avariance = (ObsPriorPrecision + FtOF)\speye(nFactorsK-1, nFactorsK-1);
Term = sum(factor.*(smallPrecision*ydemut(allBut1,:)),2);
Amean = Avariance*(ObsPriorPrecision*ObsPriorMean' + Term);
pdfA = logmvnpdf(ObsModel', Amean', Avariance);
% F | A
ObsModel1 = [1;ObsModel];
AOI = ObsModel1'*obsPrecision;
Fvariance = (factorPrecision + kron(speye(T),AOI*ObsModel1))\eye(nFactorsT);
Fmean = Fvariance*(kron(speye(T), AOI)*ydemut(:));
pdfF = logmvnpdf(factor(:)', Fmean', Fvariance);
pdfval = pdfA- pdfF;
end
