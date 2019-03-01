function [xt, lastMean, lastHessian] = ...
    optimizeA(x0, ydemut, obsPrecision, factor,factorPrecision,...
     RestrictionLevel, lastMean, lastHessian, options)


if RestrictionLevel == 1
    [xt, lastMean, lastHessian] = restrictedDraw(x0, ydemut, obsPrecision, factor,...
        factorPrecision,  lastMean, lastHessian, options);
elseif RestrictionLevel == 0
    xt = unrestrictedDraw(x0, ydemut, obsPrecision, factor, factorPrecision,...
        lastMean, lastHessian, options);
else
    error('Restriction level must be 1 or 0')
end

end

