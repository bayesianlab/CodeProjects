function [ e, pp ] = splineError1( n )
x = linspace(-5,5,n);
xx = -5:.05:5;
y = runge(x);
pp = spline(x,y, xx); 

% Truth - approx
e = abs((runge(xx) - pp)');

end

