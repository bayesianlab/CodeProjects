function [ H ] = probitJ(y,x,params )
qi = 2.*y - 1;
xBeta = qi.*x*params;
lambdai = normpdf(xBeta,0,1)./normcdf(xBeta,0,1);
H = (-lambdai.*(lambdai + x*params) .* x)' * x;
end

