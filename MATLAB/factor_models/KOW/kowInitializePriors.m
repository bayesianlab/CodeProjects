function [Si, ObsPriorMean, ObsPriorVar, ...
WorldObsModelPriorPrecision, WorldObsModelPriorlogdet,...
CountryPriorPrecision, CountryPriorlogdet, stateTransitions,...
beta, currobsmod, StateObsModel, Ft, obsVariance,obsPrecision] = ...
    kowInitializePriors(K,T, initobsmod, ...
        EqnsPerBlock, SeriesPerCountry, initGamma, initBeta, ...
        IRegion, ICountry, nFactors, yt)
stateTransitionsAll = initGamma'*eye(nFactors);
stateTransitions = initGamma.*ones(nFactors,1);
Si = kowStatePrecision(stateTransitionsAll, 1, T);
obsPrecision = ones(K,1);
obsVariance = 1./obsPrecision;
ObsPriorMean = ones(1,K).*1e-2;
ObsPriorVar = eye(K).*1e3;
WorldObsModelPriorPrecision = 1e-2.*eye(EqnsPerBlock);
WorldObsModelPriorlogdet = EqnsPerBlock*log(1e-2);
CountryPriorPrecision = 1e-2.*eye(SeriesPerCountry);
CountryPriorlogdet = SeriesPerCountry*log(1e-2);
beta = initBeta;
currobsmod= initobsmod;
StateObsModel = [currobsmod(:,1), IRegion.*currobsmod(:,2),...
    ICountry.*currobsmod(:,3)];
vecF = kowUpdateLatent(yt(:), StateObsModel, Si, obsVariance) ;
Ft = reshape(vecF, nFactors,T);obsPrecision = ones(K,1);
obsVariance = 1./obsPrecision;
end

