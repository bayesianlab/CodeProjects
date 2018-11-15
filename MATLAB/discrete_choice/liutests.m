clear;clc;
burnin = 0;
N = 10000;
K = 4;
R = zeros(K);
rho = [.7, .2, .1];
for i = 1:K
    R(i, :) = [0, circshift(rho,i-1)];
end

R = (eye(K) + triu(R,1)) + triu(R,1)';


z = mvnrnd(zeros(K,1), R, N)';

y = double(z>0);

R0 = diag(diag(z*z').^(-.5))*(z*z')*diag(diag(z*z').^(-.5));
sims = 100;
lu = log(unifrnd(0,1,sims,1));
accept = 0;
wishartDf = N;

for i = 1:sims
    z = updateLatentZ(y, zeros(K,N), R0);
    WishartParameter = z*z';
    dw = diag(WishartParameter);
    idwhalf = dw.^(-.5);
    Sstar = diag(idwhalf) * WishartParameter * diag(idwhalf);
    canW = iwishrnd(Sstar, wishartDf);
    d0 = diag(canW).^(.5);
    canD = diag(d0);
    canD0i = diag(d0.^(-1));
    canR = canD0i * canW * canD0i;
    mhprob = min(0,.5*(K+1)*(logdet(canR) - logdet(R0)));
    if lu(i) < mhprob
        accept = accept + 1;
        R0 = canR
        D0 = canD;
        W0 = canW;
    end
end