function [ themean,Hessian ] = kowOptimize( guess,  StatePrecision,...
     precision,oldMean, oldHessian, options, MaxRecursionDepth, ObsPriorMean,ObsPriorVar, factor, yt )
if MaxRecursionDepth == 2
    themean = oldMean;
    Hessian = oldHessian;
else
    guess
    yt
    
    ObsPriorMean
    ObsPriorVar
    precision
    factor
    full(StatePrecision)
    loglike = @(guess) kowRatioLL(yt, guess,ObsPriorMean,ObsPriorVar,precision,factor,StatePrecision);
    [themean, ~,flag,~,~, Hessian] = fminunc(loglike, guess, options);
    [~,notpd] = chol(Hessian);
    if notpd > 0
        fprintf('Did not optimize, tyring new point. Attempt: %i\n',...
            MaxRecursionDepth)
        MaxRecursionDepth = MaxRecursionDepth + 1;
        guess = guess + normrnd(0,1,length(guess),1);
        [themean, Hessian] = kowOptimize(guess, StatePrecision,  precision,...
            oldMean, oldHessian, options, MaxRecursionDepth, ObsPriorMean,ObsPriorVar, factor, yt);
    end
end

end

