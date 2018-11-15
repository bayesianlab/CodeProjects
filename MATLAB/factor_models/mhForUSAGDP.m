function [ retval ] = mhForUSAGDP(y, ObsModelGuess, ObsVariance, Sworld, Sregion, Scountry )
ObsModelPriorMean = zeros(3,1); 
ObsModelPriorCov = eye(3)*10;
df = 15;
a = [0, 0,0];
b = [Inf, Inf, Inf];
dll = @(guess) kowll(y, 1, guess, Sworld, Sregion, Scountry, .1);
[ObsModelMean, ObsModelHess] = bhhh(ObsModelGuess, dll, 3, .1, .5);
dhess = diag(ObsModelHess);
Candidate = geweke91T(a,b,ObsModelMean,diag(dhess), df, 1);
%             [~,p] = chol(ahess)
Num = log(mvnpdf(Candidate, ObsModelPriorMean,ObsModelPriorCov)) + ...
    kowLogLike(y, Candidate, ObsVariance, Sworld, Sregion, Scountry) +...
     log(ttpdf(a(1), b(1), ObsModelMean(1), dhess(1), df, ObsModelGuess(1))) + ...
     log(ttpdf(a(2), b(2), ObsModelMean(2), dhess(2), df, ObsModelGuess(2))) + ...
     log(ttpdf(a(3), b(3), ObsModelMean(3), dhess(3), df, ObsModelGuess(3)));
Den = log(mvnpdf(ObsModelGuess, ObsModelPriorMean,ObsModelPriorCov)) + ...
    kowLogLike(y, ObsModelGuess, ObsVariance, Sworld, Sregion, Scountry) +...
     log(ttpdf(a(1), b(1), ObsModelMean(1), dhess(1), df, Candidate(1))) + ...
     log(ttpdf(a(2), b(2), ObsModelMean(2), dhess(2), df, Candidate(2))) + ...
     log(ttpdf(a(3), b(3), ObsModelMean(3), dhess(3), df, Candidate(3)));

alpha = min(0, Num-Den);

if log(unifrnd(0,1)) <= alpha
    retval = Candidate;
else
    retval = ObsModelGuess;
end


end

