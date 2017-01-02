function [ Hessian ] = ddProbit( beta, X, y )

bigPhi = normcdf((X*beta));
negBigPhi = normcdf((-X*beta));
littlePhi = normpdf((X*beta));
[r,c] = size(X);
num = y.*(((X*beta).*bigPhi) + littlePhi);
den = bigPhi.^2;
left = num./den;
numR = (1-y).*(((X*beta).*negBigPhi)-littlePhi);
denR = negBigPhi.^2;
right = numR./denR;
inBracs = littlePhi.*(left - right);
bigMatrix = kron(ones(1,c), inBracs);
leftSide = bigMatrix.*X;
Hessian = -(leftSide' * X);

end

