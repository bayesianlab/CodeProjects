function [z, na] = ghkmvnrndBugFix(a,b,mu,sigma,N)
[J,~] = size(sigma);
us = unifrnd(0,1,J,1);
L = chol(sigma, 'lower');
offDiagonals = tril(L, -1);
yDim = 1:J;
eta = zeros(J,N);
aj = zeros(J,1);
bj = zeros(J,1);
Fb = zeros(J,1); 
Fa = zeros(J,1);
for i = 1:N
    for j = yDim
        update = mu(j) + (offDiagonals(j,:)*eta(:,i));
        aj(j) = (a(j) - update)/L(j,j);
        bj(j) = (b(j) - update)/L(j,j);
        Fb(j) = normcdf(bj(j),0,1);
        Fa(j) = normcdf(aj(j),0,1);
        eta(j,i) = norminv(us(j)*(Fb(j)-Fa(j)) + Fa(j));
    end
    if sum(~isfinite(eta(:,i))) > 0
        fprintf('in ghk problem\n')
        [a,b,mu]
        L
        z
        na = 1;
        save('ErrorOutputBug.mat')
        break
    end
end
z = (L*eta + mu);

end