x0 = [10, 0];
fun = @(x)3*x(1)^2 + 2*x(1)*x(2) + x(2)^2 - 4*x(1) + 5*x(2);
[x, fval] = fminunc(fun, x0)

