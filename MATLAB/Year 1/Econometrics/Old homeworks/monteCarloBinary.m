function [ betaHats] = monteCarloBinary( nSims, sampleSize, xData,...
    betaTrue)
 
betaHats = zeros(nSims, 1);
xData = datasample(xData, sampleSize);
for i = 1:nSims
    error = randomBernoullis(length(xData));
    dependent = dgp(xData, betaTrue, error);
    olsEst = betaOLS(xData, dependent);
    betaHats(i,1) = olsEst(2,1);
end

end


