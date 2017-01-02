function [ Hessian ] = logitDD( beta, X, y )
bigPhi = cdf('Logistic', X*beta,0,1);
nByOne = bigPhi.*(1-bigPhi);
[r,c] = size(X);
kronecker = kron(ones(1,c), nByOne);
preMult = (kronecker.*X)';
Hessian = -(preMult*X);

end

