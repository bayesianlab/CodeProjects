function [z, logpdf] = tmultnormrndEta(a, b, mu, Sigma, N)
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
Ljj = diag(L);
LjjInv = Ljj.^(-1);
offDiagonals = tril(L, -1);
yDim = 1:J;
eta = zeros(N, J);
eta2 = zeros(N, J);
alpha = a-mu;
beta = b-mu;
logpdf = zeros(N,1);
for i = 1:N
    p = 0;
    for j = yDim
        update =  (offDiagonals(j,:)*eta(i,:)');
        aj = (alpha(j) - update)*LjjInv(j);
        bj = (beta(j) - update)*LjjInv(j);
        eta(i,j) = truncNormalRand(aj,bj,0,1);
        p = p +  log(LjjInv(j)*tnormpdf(aj, bj, 0, 1, eta(i,j)));
    end
    logpdf(i) = p;
end
z = (L*eta')' + mu';
end



