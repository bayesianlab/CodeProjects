function [ seriesVal ] = sinSeries( iteration,  x )
den = 2*iteration + 1;
seriesVal = (x^den)/factorial(den);
end

