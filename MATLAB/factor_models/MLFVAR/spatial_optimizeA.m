function [xt, lastMean, lastHessian] = spatial_optimizeA(x0, ydemut, obsPrecision, factor,factorPrecision,...
      lastMean, lastHessian, options, identification)
  identification
if identification == 1
    [xt, lastMean, lastHessian] = restrictedDraw(x0, ydemut, obsPrecision, factor,...
        factorPrecision,  lastMean, lastHessian, options);
elseif identification == 2
    xt = spatial_identification2(x0, ydemut, obsPrecision, factor, factorPrecision,...
        lastMean, lastHessian, options);
else
    error('Identification must be 1 or 2')
end
end

