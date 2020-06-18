function [P0, P0lower, R, notvalid] = CalcInitCovar(ssgamma, sigmau,lags)
K=length(sigmau);
KL = size(ssgamma,1);
Kss2 = (KL)^2;
notvalid=0;
R = spdiags(sigmau, 0, KL,K);
sRR = (R*R');
P0 = reshape((eye(Kss2) - kron(ssgamma,ssgamma)) \ sRR(:), KL, KL);
[P0lower,p]  = chol(P0, 'lower');
if p ~= 0 
    notvalid = 1;
end
end

