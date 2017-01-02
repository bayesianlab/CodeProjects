function [ sderiv ] = dprobit( beta, X, y )
format long g
littlePhi = normpdf(X*beta);
bigPhi = normcdf(X*beta);
negBigPhi = normcdf(-X*beta);
left = (y.*littlePhi)./bigPhi;
numR = (1-y).*littlePhi;
denR = negBigPhi;
right = numR./denR;
inbrack = (left - right)';
sderiv = inbrack*X;
sderiv = sderiv';
end

