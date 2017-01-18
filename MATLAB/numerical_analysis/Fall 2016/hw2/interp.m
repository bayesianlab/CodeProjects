function [ interpPolynomial] = interp(xValues, evaledXvalues, range, detail)
n = length(xValues);
coefs = dividedDifferences(xValues, evaledXvalues);
check = linspace(range(1), range(2), detail);
pOfn = evalPoints(xValues(1:(n-1)), coefs, check);
interpPolynomial = [check; pOfn'];
end

