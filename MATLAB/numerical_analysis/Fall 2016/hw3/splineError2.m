function [ e, pp ] = splineError2( n )
x = linspace(-2*pi,2*pi,n);
xx = -2*pi:.05:2*pi;
y = wavySin(x);
pp = spline(x,y, xx); 
% Truth - approx
e = abs((wavySin(xx) - pp)');
end