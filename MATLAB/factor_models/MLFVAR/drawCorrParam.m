function [parama] = drawCorrParam(parama, tuningVar, cutpoints, CorrType,  yt,...
    StateObsModel, LocationCorrelation, Ft, seriesPerY)
priorVariance = 10;
if CorrType == 1
    % Nearest Neighbor
    Lower = (cutpoints(1) - parama)/tuningVar;
    Upper = (cutpoints(2) - parama)/tuningVar;
    prop = parama + tuningVar*twoSided(Lower,Upper);
    eyePy = eye(seriesPerY);
    LCN = kron(eyePy, createSpatialCorr(LocationCorrelation, prop, CorrType));
    LCD = kron(eyePy, createSpatialCorr(LocationCorrelation, parama, CorrType));
    LikeN = sum(logmvnpdf(yt', (StateObsModel*Ft)', LCN));
    LikeD = sum(logmvnpdf(yt', (StateObsModel*Ft)', LCD));
    propN = logmvnpdf(prop, parama, tuningVar);
    propD = logmvnpdf(parama, prop, tuningVar);
    priorN = logmvnpdf(0, prop,priorVariance);
    priorD = logmvnpdf(0, parama, priorVariance);
else
    % Euclidean Distance
    prop =  truncatedBelow(0, parama, tuningVar);
    eyePy = eye(seriesPerY);
    LCN = kron(eyePy, createSpatialCorr(LocationCorrelation, prop, CorrType));
    LCD = kron(eyePy, createSpatialCorr(LocationCorrelation, parama, CorrType));
    LikeN = sum(logmvnpdf(yt', (StateObsModel*Ft)', LCN));
    LikeD = sum(logmvnpdf(yt', (StateObsModel*Ft)', LCD));
    propN = logmvnpdf(parama, prop, tuningVar);
    propD = logmvnpdf(prop, parama, tuningVar);
    priorN = logmvnpdf(prop, 1,priorVariance);
    priorD = logmvnpdf(parama, 1, priorVariance);
    
end


alpha = min(0 , (LikeN + propN + priorN) - LikeD - propD - priorD);

if log(unifrnd(0,1)) < alpha
    parama = prop;
end
end
