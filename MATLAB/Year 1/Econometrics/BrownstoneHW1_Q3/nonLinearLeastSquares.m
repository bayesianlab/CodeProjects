function [ summation ] = nonLinearLeastSquares( beta, X, y)
[r,c] = size(X);
prob = cdf('Normal', X*beta, 0,1);
middle = (y- prob).^2;
unos = ones(r, 1);
summation = middle'*unos;

end

