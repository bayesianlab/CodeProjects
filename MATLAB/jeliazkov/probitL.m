function [ L ] = probitL(y,x,params)
qi = 2*y - 1;
L = sum(log(normcdf(qi.*x*params,0,1)));
end

