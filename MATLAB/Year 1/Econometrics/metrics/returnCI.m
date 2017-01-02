function [ CI ] = returnCI( data, xDataLen, bootstrapRuns, level, betaHat, ...
    populationVar)
% Computes the bootstrapT
sortedData = sort(data);
upperBound = round(bootstrapRuns*(1-(level /100.0)));
upperBound = (sortedData(upperBound, 1));
CI = betaHat(2,1)  + (upperBound*sqrt(populationVar(2,2)));
end

