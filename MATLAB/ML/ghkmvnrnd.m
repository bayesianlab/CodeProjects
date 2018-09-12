function [z, na] = ghkmvnrnd(a,b,mu,sigma,N)
[J,~] = size(sigma);
L = chol(sigma, 'lower');
offDiagonals = tril(L, -1);
yDim = 1:J;
eta = zeros(J,N);
for i = 1:N
    for j = yDim
        update = mu(j) + (offDiagonals(j,:)*eta(:,i));
        aj = (a(j) - update)/L(j,j);
        bj = (b(j) - update)/L(j,j);
        Fb = normcdf(bj,0,1);
        Fa = normcdf(aj,0,1);
        eta(j,i) = norminv(unifrnd(0,1,1)*(Fb-Fa) + Fa);
    end
end
z = (L*eta + mu);
if sum(~isfinite(z)) > 0
    fprintf('in ghk problem\n')
    [a,b,mu]
    L
    z
    na = 1;
else
    na =0;
end

end

