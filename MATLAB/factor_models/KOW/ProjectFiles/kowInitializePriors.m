function [Si, ObsPriorMean, ObsPriorVar, stateTransitions,...
beta, currobsmod, StateObsModel, Ft, obsVariance,obsPrecision] = ...
    kowInitializePriors(K,T, initobsmod, EqnsPerBlock,...
        SeriesPerCountry, initGamma, initBeta, ...
        IRegion, ICountry, nFactors, yt)
stateTransitionsAll = initGamma.*eye(nFactors);
stateTransitions = initGamma.*ones(nFactors,1);
Si = kowStatePrecision(stateTransitionsAll, 1, T);
obsPrecision = ones(K,1);
obsVariance = 1./obsPrecision;
ObsPriorMean = initobsmod';
ObsPriorVar = eye(K).*1e2;
beta = initBeta;
currobsmod= initobsmod;
StateObsModel = [currobsmod(:,1), IRegion.*currobsmod(:,2),...
    ICountry.*currobsmod(:,3)];
vecF = kowUpdateLatent(yt(:), StateObsModel, Si, obsVariance) ;
Ft = reshape(vecF, nFactors,T);
obsPrecision = ones(K,1);
obsVariance = 1./obsPrecision;
end

