function [x] = tlnrnd(a,b,mu,sigma, N)
beta = sigma.^(-1).*(b - mu);
alpha = sigma.^(-1).*(a-mu);
Fa = normcdf(alpha);
FbMFa = normcdf(beta) -  Fa;
x = sigma*norminv(unifrnd(0,1, N, 1)*FbMFa + Fa) + mu;
end

