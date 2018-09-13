function [c] = ghkmvnrndBug(a,b,mu,sigma,N, us)
[J,~] = size(sigma);
us = [us, unifrnd(0,1,J,N)];
L = chol(sigma, 'lower');
offDiagonals = tril(L, -1);
yDim = 1:J;
eta = zeros(J,N);
c = 0;
for i = 1:N
    baddraw = 1;
    while baddraw == 1
        for j = yDim
            update = mu(j) + (offDiagonals(j,:)*eta(:,i));
            aj = (a(j) - update)/L(j,j);
            bj = (b(j) - update)/L(j,j);
            Fb = normcdf(bj,0,1);
            Fa = normcdf(aj,0,1);
            eta(j,i) = norminv(us(j,i)*(Fb-Fa) + Fa);
        end
        if sum(sum(~isfinite(eta(:,i)))) > 0
            c = c + sum(sum(~isfinite(eta(:,i))));
            us(:,i) = unifrnd(0,1,J,1);
            eta(:,i) = zeros(J,1);
        else
            baddraw = 0;
        end
    end
end
z = (L*eta + mu);
end
