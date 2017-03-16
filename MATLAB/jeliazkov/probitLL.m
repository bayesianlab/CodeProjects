function [ ll] = probitLL( y,x,params)
qi = 2.*y - 1;
xBeta = qi.*x*params;
num = qi.*normpdf(xBeta, 0, 1);
den = normcdf(xBeta,0,1);
ll = sum((num./den).*x)';
end

