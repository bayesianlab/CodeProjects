function [ yyk ] = splineInterp( x_k, f_k, xx )
f_k = [1, f_k, 1];
yyk = spline(x_k, f_k, xx);
end

