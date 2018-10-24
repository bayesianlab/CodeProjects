function [ ] = mhStepTwoRestrictioins( y, ObsModelGuess, ObsVariance, Sworld, Sregion, Scountry)
ObsModelPriorMean = zeros(3,1); 
ObsModelPriorCov = eye(3)*10;
a = [-Inf, 0,0];
b = [Inf, Inf, Inf];
dll = @(guess) kowll(y, 1, guess, Sworld, Sregion, Scountry, .1);
[ObsModelMean, ObsModelHess] = bhhh(ObsModelGuess, dll, 3, .1, .5);
Candidate = geweke91T(a,b,ObsModelMean,ObsModelHess, 15, 1);
Num = log(mvnpdf(Candidate, ObsModelPriorMean,ObsModelPriorCov))

kowLogLike(y, Candidate, ObsVariance, Sworld, Sregion, Scountry)
end

