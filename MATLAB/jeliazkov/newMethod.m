function [ z ] = newMethod( a, b, mu, sigma, sampleSize, burn )
[J, ~] = size(sigma);
mineigval = min(eig(sigma))- .02;
lamb = mineigval*eye(J) 
u = zeros(sampleSize, J);
V = mvnrnd(zeros(1,J), lamb, sampleSize);
omega = sigma - lamb
lower = chol(omega, 'lower')

offDiag = tril(lower, -1);
for sim =  1:sampleSize
    for j = 1:J
        update = mu(j) + V(sim,j) + offDiag(j,:)*u(sim, :)';
        aj = (a - update)/lower(j,j);
        bj = (b - update)/lower(j,j);
        Fb = normcdf(bj,0,1);
        Fa = normcdf(aj,0,1);
        u(sim,j) = norminv(unifrnd(0,1,1)*(Fb-Fa) + Fa);
    end
end
V= V(burn+1:sampleSize,:);
u = u(burn+1:sampleSize,:);
z = mu + V + (lower*u')';
end

