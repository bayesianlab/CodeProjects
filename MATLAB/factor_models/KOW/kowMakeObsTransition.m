function [ Transition ] = kowMakeObsTransition(ObsModel, Neqns,RegionIndices,SeriesPerCountry, Countries )
[I1, I2] = kowMakeObsModelIdentityMatrices(Neqns, RegionIndices,...
    SeriesPerCountry, Countries);
Transition = [ObsModel(:,1), I1.*ObsModel(:,2), I2.*ObsModel(:,3)];
end

