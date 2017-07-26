function [ z ] = ghkGibbsSampler( a,b, mu, sigma, sims )
% draw from truncated normal(0,1) with linear constraints
[J,~] = size(sigma);
L = chol(sigma, 'lower');
offDiagonals = tril(L, -1);
yDim = 1:J;
eta = zeros(sims, J);
for sim = 2:(sims)
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

