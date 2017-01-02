function [ CI ] = theoreticalCI( betaHat, sampleSize,...
    variance, tStat)
CI = betaHat + (tStat * sqrt(variance)*(1/sqrt(sampleSize)));
end

