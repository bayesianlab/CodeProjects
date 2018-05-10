function [A,SigmaHat,D0inv] = gibbsvar(yt,p,b0,B0, lambda0, S0, sims,burn)
% yt expected to be organized y1t,y2t...,ykt
[yt,xt] = lagYt(yt,p);
[T, K] = size(yt);
nparams = K*(K*p+1);
yt = yt';
vecy = yt(:);
z = xt';
zzT = z*z';
IK = eye(K);
B0inv = inv(B0);
B0invb0 = B0inv*b0;
SigmaInv = eye(K);
lambdaupbar = lambda0 + T;
alphaMat = zeros(sims-burn,nparams);
c = 0;
for i = 1:sims
    Vupbar = inv( kron(zzT, SigmaInv) + B0inv);
    alphaupbar = Vupbar*(B0invb0 + kron(z, SigmaInv)*vecy);
    alpha = alphaupbar + chol(Vupbar,'lower')*normrnd(0,1,[nparams,1]);
    resid = yt - reshape(alpha, K, p*K+1)*z;
    Supbar = (resid*resid') + S0;
    SigmaInv = wishrnd(Supbar, lambdaupbar);
    if i >= burn
        c = c + 1;
        alphaMat(c,:) = alpha';
    end
end
A = reshape(mean(alphaMat)', K,p*K+1);
resid = yt - A*z;
df = (T-p-(p*K+1));
if df < 0
    SigmaHat = resid*resid'/ T;
else
    SigmaHat = resid*resid'/ df;
end
D0inv = chol(SigmaHat,'lower');



