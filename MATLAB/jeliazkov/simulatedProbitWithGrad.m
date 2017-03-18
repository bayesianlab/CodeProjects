function [ f,g ] = simulatedProbitWithGrad(b, ARmethodSimulatedMoments, probitSimulatedScore)
f = ARmethodSimulatedMoments(b);

if nargout > 1
    g = -probitSimulatedScore(b);
end

