function [ betaHats ] = monteCarloNormalEr( nSims, sampleSize, xData,...
    betaTrue)
% Calculate beta hats on random draws from data. Puts in a vector,
% only returns vector of coefficents, not constants. 
 
betaHats = zeros(nSims, 1);
xData = datasample(xData, sampleSize);
for i = 1:nSims
    error = normrnd(0,3, length(xData),1);
    dependent = dgp(xData, betaTrue, error);
    olsEst = betaOLS(xData, dependent);
    betaHats(i,1) = olsEst(2,1);
end

end

