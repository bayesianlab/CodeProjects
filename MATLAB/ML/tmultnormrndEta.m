function [z] = tmultnormrndEta(a, b, mu, Sigma, N)
[J,~] = size(Sigma);
L = chol(Sigma, 'lower');
if isrow(mu) 
    mu = mu';
end
if isrow(a)
    a= a';
end
if isrow(b)
    b = b';
end
% draw from truncated normal(0,1) with linear constraints
L = chol(Sigma, 'lower');
offDiagonals = tril(L, -1);
yDim = 1:J;
eta = zeros(N, J);
alpha = a-mu;
beta = b-mu;
for sim = 1:(N)
    for j = yDim
        update =  (offDiagonals(j,:)*eta(sim,:)');
        aj = (alpha(j) - update)/L(j,j);
        bj = (beta(j) - update)/L(j,j);
        eta(sim,j) = truncNormalRand(aj,bj,0,1);
    end
end

z = (L*eta' + mu)';
end



