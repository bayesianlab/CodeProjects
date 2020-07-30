function [] = RunMvprobit_Correlation(filename, K, nFactors)


T = 100;
Q = 1;
X = [ones(T*K,1), normrnd(0,1,T*K, Q-1)];
R = createSigma(.7, K);
beta = ones(Q,1);
zt = reshape(X*beta,K,T) +  chol(R,'lower')*normrnd(0,1,K,1);
yt = double(zt > 0);

Sims=10;
bn = 1;
cg = 0;
initFt = normrnd(0,1,nFactors,T);
lags = 1;
g0 = zeros(1,lags);
G0=diag(fliplr(.5.^(0:lags-1)));
b0= 0;
B0 =1;
a0 = .5;
A0= 10;
estml = 1;

for k = 1:nFactors
    InfoCell{k} = [k, K];
end


[Output] =GeneralMvProbit(yt, X, Sims, bn, cg, estml, b0, B0, g0, G0, a0, A0,...
    initFt, InfoCell);

save(filename)

end
