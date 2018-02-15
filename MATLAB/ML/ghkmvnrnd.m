function [z] = ghkmvnrnd(a,b,mu,sigma,N)
[J,~] = size(sigma);
L = chol(sigma, 'lower');
offDiagonals = tril(L, -1);
yDim = 1:J;
eta = zeros(sims, J);
for sim = 1:N
    for j = yDim
        update = mu(j) + (offDiagonals(j,:)*eta(sim,:)');
        aj = (a - update)/L(j,j);
        bj = (b - update)/L(j,j);
        Fb = normcdf(bj,0,1);
        Fa = normcdf(aj,0,1);
        eta(sim,j) = norminv(unifrnd(0,1,1)*(Fb-Fa) + Fa);
    end
end
z = (L*eta' + mu')';
end

