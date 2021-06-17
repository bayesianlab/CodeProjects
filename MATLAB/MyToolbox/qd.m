function [i] = qd(f1,f2,f1p,x1,x2)
a = (f1-f2-f1p*(x1-x2)) / (-(x1-x2)^2);
b = f1p - 2*x1*a;
i= -b/(2*a);
end

