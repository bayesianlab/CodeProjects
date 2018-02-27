function [t, logpdf] = ghkT(a, b, mu, Sigma, nu, N)
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
L = chol(Sigma, 'lower');
Ljj = diag(L);
LjjInv = Ljj.^(-1);
offDiagonals = tril(L, -1);
yDim = 1:J;
w= chi2rnd(nu,N,1);
rootw = sqrt(w/nu);
eta = zeros(N, J);
eta2 = zeros(N, J);
alpha = a-mu;
beta = b-mu;
logpdf = zeros(N,1);
df =zeros(J,1);
for j = 1:J
    df(j) = nu + j - 1;
end
for i = 1:N
    p = 0;
    for j = yDim
        update =  (offDiagonals(j,:)*eta(i,:)');
        aj = (alpha(j) - update)*rootw(i)*LjjInv(j);
        bj = (beta(j) - update)*rootw(i)*LjjInv(j);
        eta(i,j) = truncNormalRand(aj,bj,0,1)/rootw(i);
        p = p + log(LjjInv(j)) + log(ttpdf(aj,bj,0,1,df(j),eta(i,j)));
    end
    logpdf(i) = p;
end
t = (L*eta')' + mu';
end


