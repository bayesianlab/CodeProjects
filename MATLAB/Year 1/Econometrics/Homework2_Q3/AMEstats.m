function [ meanAME, stdAME ] = AMEstats( BetaSample, X, c )
% This function finds the mean and standard deviation of the average
% marginal effects for a logit model.
% Takes in: A matrix of sampled betas, the data, and which column of data (which covariat) to analyze.
% Outputs two scalars.

[n,k] = size(X);
[k,s] = size(BetaSample);

ame = zeros(s,1);  % initialize for speed
for j=1:s
    sum = 0;  % reset inner loop parameter
    for h=1:n
        p = 1/(1+exp(-X(h,:)*BetaSample(:,j)) );
        sum = sum + BetaSample(c,j)*p*(1-p);
    end
    ame(j) = sum/n;
end

meanAME = mean(ame);
stdAME = std(ame);

end

