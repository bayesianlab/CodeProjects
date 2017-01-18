function [ table ] = generateData1(X_is, coefs, abRange, n)
xvals = linspace(abRange(1), abRange(2), n);
evaledPnts = evalPoints(X_is, coefs, xvals);
table = [xvals;evaledPnts'];
end

