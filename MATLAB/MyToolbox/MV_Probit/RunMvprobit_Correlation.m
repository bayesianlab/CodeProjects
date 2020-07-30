function [] = RunMvprobit_Correlation(filename, K, nFactors, Sims, bn)
if ischar(K)
    K = str2num(K);
end
if ischar(Sims)
    Sims= str2num(Sims);
end
if ischar(bn)
    bn= str2num(bn);
end
if ischar(nFactors)
    nFactors= str2num(nFactors);
end
T = 100;
Q = 1;
X = [ones(T*K,1)];
R = createSigma(.7, K);
beta = ones(Q,1);
zt = reshape(X*beta,K,T) +  chol(R,'lower')*normrnd(0,1,K,1);
yt = double(zt > 0);

Sims=10000;
bn = 1000;
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
