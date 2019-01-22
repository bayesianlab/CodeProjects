function [ themean,Hessian ] = kowOptimize( guess,  StatePrecision,...
     precision,oldMean, oldHessian, options, MaxRecursionDepth, ObsPriorMean,ObsPriorVar, factor, yt )
if MaxRecursionDepth == 2
    themean = oldMean;
    Hessian = oldHessian;
else
    loglike = @(guess) kowRatioLL(yt, guess,ObsPriorMean,ObsPriorVar,precision,factor,StatePrecision);
    [themean, ~,~,~,~, Hessian] = fminunc(loglike, guess, options);
%     themean = -themean;
    [~,notpd] = chol(Hessian);
    if notpd > 0
        fprintf('Did not optimize, tyring new point. Attempt: %i\n',...
            MaxRecursionDepth)
        MaxRecursionDepth = MaxRecursionDepth + 1;
        guess = guess + normrnd(0,1,length(guess),1);
        [themean, Hessian] = kowOptimize(guess, StatePrecision,  precision,...
            oldMean, oldHessian, options, MaxRecursionDepth, ObsPriorMean,ObsPriorVar, factor, yt);
%         themean = -themean;
    end
end

end

