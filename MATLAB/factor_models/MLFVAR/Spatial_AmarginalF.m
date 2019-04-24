function [obsupdate, backup, f, vdecomp] = ...
    Spatial_AmarginalF( LocationCorrelationPrecision, Factor, yt, ...
      currobsmod,  stateTransitions, factorVariance,...
      backup, options, identification, vy)
[K,T] = size(yt);
u = 0;
vdecomp = zeros(K,1);
factorPrecision = kowStatePrecision(stateTransitions, factorVariance, T);
lastMean = backup{1,1};
lastHessian = backup{1,2};
[obsupdate, lastMean, lastHessian] = spatial_optimizeA(currobsmod, yt,...
    LocationCorrelationPrecision,  Factor, factorPrecision, lastMean, lastHessian, options, identification);
backup{1,1} = lastMean;
backup{1,2} = lastHessian;
f =  spatial_UpdateLatent(yt(:),  obsupdate, factorPrecision, LocationCorrelationPrecision);
obsmodSquared = obsupdate.^2;

for m = 1:size(yt,1)
    u = u + 1;
    vdecomp(u) = (obsmodSquared(m) .* var(f)) ./ vy(m);
end

end

