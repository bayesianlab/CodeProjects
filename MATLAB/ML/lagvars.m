function [y] = lagvars(x, lags)
[r,c] = size(x);
x1 = x(1:r - lags,:);
y = [x(lags+1:r,:), x1];
end

