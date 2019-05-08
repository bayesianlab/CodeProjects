function [xt, lastMean, lastCovar] = ...
    optimizeA(x0, ydemut, obsPrecision, factor,factorPrecision,...
      lastMean, lastCovar, options, identification)


if identification == 1
    [xt, lastMean, lastCovar] = restrictedDraw(x0, ydemut, obsPrecision, factor,...
        factorPrecision,  lastMean, lastCovar, options);
elseif identification == 2
    [xt, lastMean, lastCovar] = identification2(x0, ydemut, obsPrecision, factor, factorPrecision,...
        lastMean, lastCovar, options);
else
    error('Identification must be 1 or 2')
end

end

