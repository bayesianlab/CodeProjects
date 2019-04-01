function [xt, lastMean, lastHessian] = ...
    optimizeA(x0, ydemut, obsPrecision, factor,factorPrecision,...
      lastMean, lastHessian, options, identification)


if identification == 1
    [xt, lastMean, lastHessian] = restrictedDraw(x0, ydemut, obsPrecision, factor,...
        factorPrecision,  lastMean, lastHessian, options);
elseif identification == 2
    xt = identification2(x0, ydemut, obsPrecision, factor, factorPrecision,...
        lastMean, lastHessian, options);
else
    error('Restriction level must be 1 or 2')
end

end

