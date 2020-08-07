function [] = RunSp(fname, Sims, burnin) 
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end
load(fname)
yt = DataCell{1};
Xt = DataCell{2};
InfoCell = DataCell{3}; 
nFactors = length(InfoCell); 




cg = 0;
initFt = normrnd(0,1,nFactors,t);
lags = 5;
R0 = ones(K,1);
g0 = zeros(1,lags);
% G0 = .5
G0=diag(fliplr(.5.^(0:lags-1)));
b0= 0;
B0 =10;
a0 = .5;
A0= 10;
s0 = 6;
S0 = 6;
v0 = 6;
r0 = 6;

estml = 1;
[Output] =GeneralMvProbit(yttrain, Xttrain, Sims, bn, cg, estml, b0, B0, g0, G0, a0, A0,...
    initFt, InfoCell);

storeBeta = Output{1};
storeFt = Output{2} ;
storeSt = Output{3};
storeOm = Output{4};
ml = Output{5};
overview = Output{6} ;

mubeta = mean(storeBeta,2);
Fhat = mean(storeFt,3);
xbeta = reshape(surForm(Xt,K)*mean(storeBeta,2), K,T);
Af = mean(storeOm,3)*Fhat;
yhat = xbeta + Af;);
name = createDateString('sp')
save(name)
end