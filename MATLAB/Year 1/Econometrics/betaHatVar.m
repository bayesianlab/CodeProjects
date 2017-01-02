function [ betaVar ] = betaHatVar( xData, resids )
sigmaSquared = sum(resids.^2)/ length(resids-2);
betaVar =  sigmaSquared * inv(xData' * xData);
end

