function [xt, lastMean, lastHessian] = ...
    optimizeA(x0, ydemut,ObsPriorMean, ObsPriorVar, obsPrecision, factor,factorPrecision, lastMean, lastHessian, RestrictionLevel, options)

[K,T] = size(ydemut);
if RestrictionLevel == 1
    LogLikePositive = @(v) AproptoLLLevel1 (guess, ydemut,ObsPriorMean, ObsPriorVar, obsPrecision, factor,factorPrecision);
    LL = @(guess) -AproptoLLLevel1 (guess, ydemut,ObsPriorMean, ObsPriorVar, obsPrecision, factor,factorPrecision);
     [themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
     [~, p] = chol(Hessian);
elseif RestrictionLevel == 2
     LogLikePositive = @(v) AproptoLLLevel2 (guess, ydemut,ObsPriorMean, ObsPriorVar, obsPrecision, factor,factorPrecision);
     LL = @(guess) -AproptoLLLevel2 (guess, ydemut,ObsPriorMean, ObsPriorVar, obsPrecision, factor,factorPrecision);
     [themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
     [~, p] = chol(Hessian);
elseif Restriction == 3
     LogLikePositive = @(v) AproptoLLLevel3 (guess, ydemut,ObsPriorMean, ObsPriorVar, obsPrecision, factor,factorPrecision);
      LL = @(guess) -AproptoLLLevel3 (guess, ydemut,ObsPriorMean, ObsPriorVar, obsPrecision, factor,factorPrecision);
     [themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
     [~, p] = chol(Hessian);
else
    error('Restriction level must be 1-3')
end
 if p ~= 0 
     themean = lastMean;
     Hessian = lastHessian;
 else
     lastMean = themean;
     lastHessian = Hessian;
     fprintf('Optimization failure\n')
 end
df = 20;
w1 = sqrt(chi2rnd(df,1)/df);
HLowerI = chol(Hessian,'lower')\eye(length(themean));
Variance = HLowerI*HLowerI;
proposal  = themean' + H\normrnd(0,1,length(themean),1)./w1;
priorDensity = @(p) logmvnpdf(p, priorMean, priorVariance);
proposalDensity = @(q) mvtstudenttpdf(q, themean, Variance, df);

xt = MH(proposal, x0, LogLikePositive, proposalDensity, priorDensity);

xt = packageXt(xt, RestrictionLevel, K);

end

