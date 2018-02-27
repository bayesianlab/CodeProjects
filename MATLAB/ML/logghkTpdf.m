function [logpdf] = logghkTpdf(a,b,mu,Sigma, nu, sample)
[J,~] = size(Sigma);
[N,~] = size(sample)
for j= 1:J
    df(j) = nu + j - 1;
end
L = chol(Sigma, 'lower');
Ljj = diag(L);
LjjInv = Ljj.^(-1);
offDiagonals = tril(L, -1);

alpha = a-mu;
beta = b-mu;
logpdf = zeros(N,1);
for i = 1:N
    p = 0;
    for j = 1:J
        update =  (offDiagonals(j,:)*eta(i,:)');
        aj = (alpha(j) - update)*LjjInv(j);
        bj = (beta(j) - update)*LjjInv(j);
    end
end
end

