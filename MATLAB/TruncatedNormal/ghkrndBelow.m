
function [] = ghkrndBelow(a,mu,Sigma, Sims)
J = size(Sigma,2);
L = chol(Sigma, 'lower');
Ljj = diag(L);
LjjInv = Ljj.^(-1);
offDiagonals = tril(L, -1);
yDim = 1:J;
eta = zeros(J,Sims);
alpha = a-mu;
for i = 1:N
    for j = yDim
        update =  (offDiagonals(j,:)*eta(:,i));
        aj = (alpha(j) - update)*LjjInv(j);
        bj = (beta(j) - update)*LjjInv(j);
        eta(j,i) = truncNormalRand(aj,bj,0,1);
    end
end
z = mu' + L*eta;

end