function [ betaVariance ] = calcStatisticT(betaHatStar, betaHat,...
    resids, xData )
% Calculates the t statistic (bhatstar - beta) varianceMat (betahatstar -
% beta)
betaVar = betaHatVar(xData, resids);
difference = betaHatStar - betaHat;
betaVariance = difference' * betaVar * difference;
end

