function [obsupdate, backup, f] = ...
    Spatial_AmarginalF(  LocationCorrelationPrecision, Factor, yt, ...
    currobsmod,  stateTransitions, factorVariance,...
    backup, options, identification)
[K,T] = size(yt);

fp = kowStatePrecision(stateTransitions, factorVariance, T);
lastMean = backup{1,1};
lastHessian = backup{1,2};
[obsupdate, lastMean, lastHessian] = spatial_optimizeA(currobsmod, yt,...
    LocationCorrelationPrecision,  Factor, fp, lastMean, lastHessian, options, identification);
backup{1,1} = lastMean;
backup{1,2} = lastHessian;
f =  spatial_UpdateLatent(yt(:),  obsupdate, fp, LocationCorrelationPrecision);


end

