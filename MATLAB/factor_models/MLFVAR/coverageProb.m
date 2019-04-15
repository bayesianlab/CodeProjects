function [coverageP] = coverageProb(True, sumFt, sumFt2)
variance = sumFt2 - sumFt.^2;
sig = sqrt(variance);
upper = sumFt + 2.*sig;
lower = sumFt - 2.*sig;

In = (True < upper) & (True > lower);
T = size(In,2);
coverageP = sum(In,2)./T;
end

