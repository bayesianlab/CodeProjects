function [ output_args ] = finiteDifferenceHessian(F,X)
[r,c] = size(X)
eye(r);
F(X + h)
F(X - h)
end

