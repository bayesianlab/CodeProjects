function [] = ...
    MultDyFacVar(yt, Xt,  InfoMat, SeriesPerCountry, Sims, burnin, initobsmodel, initStateTransitions, v0, r0)

% InfoMat is Countries: Region info in column 1, 
% Country info in column 2
% Number of rows is equal to countries

nFactors = length(initStateTransitions);
[K,T] = size(yt);
ObsPriorMean = ones(1, K*nFactors);
ObsPriorVar = eye(K*nFactors);
lastMean = ObsPriorMean;
lastHessian = ObsPriorVar;
[IRegion, ICountry, Regions, Countries] = MakeObsModelIdentity( InfoMat, SeriesPerCountry);
RegionIndicesFt = 2:(Regions+1);
CountryIndicesFt = 1+Regions:(1+Regions+Countries);
StateObsModel = makeStateObsModel(initobsmodel,IRegion,ICountry);
Si = kowStatePrecision( diag(initStateTransitions), 1, T);
obsPrecision = ones(K,1);
stateTransitions = initStateTransitions;
currobsmod = initobsmodel;
vecF = kowUpdateLatent(yt(:), StateObsModel, Si, obsPrecision) ;
Ft = reshape(vecF, nFactors,T);
for i = 1 : Sims
    [beta, ydemut] = kowBetaUpdate(yt(:), Xt, obsPrecision,...
          StateObsModel,Si,T);
      
      
      currobsmod = AmarginalF(SeriesPerCountry, InfoMat, ...
          Ft, yt, currobsmod, ObsPriorMean, ObsPriorVar,  lastMean, lastHessian);
      StateObsModel = makeStateObsModel(currobsmod,IRegion,ICountry);
      vecFt = kowUpdateLatent(yt(:), StateObsModel, Si, obsPrecision);
      Ft = reshape(vecFt, nFactors,T);
      
       residuals = ydemut - StateObsModel*Ft;
       [obsVariance,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
        
        [WorldAr] = kowUpdateArParameters(stateTransitions(1), Ft(1,:), 1);
        [RegionAr] = kowUpdateArParameters(stateTransitions(RegionIndicesFt),...
        Ft(RegionIndicesFt,:), 1);
        [CountryAr] = kowUpdateArParameters(stateTransitions(CountryIndicesFt),...
        Ft(CountryIndicesFt,:), 1);
        stateTransitions = [WorldAr;RegionAr;CountryAr];
      
      
      
end

end

