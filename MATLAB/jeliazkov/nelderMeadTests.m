% nelderMead tests
% answers fx = 7, x = [3,2]
clear 
clc
b = [0;0]
options = optimset('Display', 'iter', 'MaxFunEvals', 10000, 'TolFun', 1e-4);
foo = @(x)  x(1)^2 - 4*x(1) + x(2)^2 - x(2) - x(1)*x(2);
fminsearch(foo, b, options)
[fx, x] = nelderMeadMin(b, foo, 40, 1e-6, 1)