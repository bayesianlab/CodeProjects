function [ themean,Hessian ] = kowOptimize( guess, vecy, StatePrecision,...
    precision,oldMean, oldHessian, options, MaxRecursionDepth )
if MaxRecursionDepth == 3
    themean = oldMean;
    Hessian = oldHessian;
else
    loglike = @(guess) -kowLL(guess, vecy, StatePrecision, precision);
    [themean, ~,~,~,~, Hessian] = fminunc(loglike, guess, options);
    themean = -themean;
    [~,notpd] = chol(Hessian);
    if notpd > 0
        fprintf('Did not optitmize, tyring new point. Attempt: %i\n',...
            MaxRecursionDepth)
        MaxRecursionDepth = MaxRecursionDepth + 1;
        guess = guess + normrnd(0,1,length(guess),1);
        [themean, Hessian] = kowOptimize(guess, vecy, StatePrecision, precision,...
            oldMean, oldHessian, options, MaxRecursionDepth);
    end
end

end

