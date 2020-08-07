load('/home/precision/CodeProjects/MATLAB/MyToolbox/MV_Probit/MVPData/sp1.mat')
yt = DataCell{1};
Xt = DataCell{2};
InfoCell = DataCell{3}; 
nFactors = length(InfoCell); 

[K,T] = size(yt);
t= 159;
Kt = K*t;
yttrain = yt(:,1:t);
Xttrain = Xt(1:Kt,:);

Sims=100;
bn = 10;
cg = 0;
initFt = normrnd(0,1,nFactors,t);
lags = 4;
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
storeFt= Output{2};
storeSt= Output{3};
storeOm = Output{4};
% summary2 = Output{6};

mubeta = mean(storeBeta,2);
Fhat = mean(storeFt,3);


% load('/home/precision/CodeProjects/MATLAB/MyToolbox/MV_Probit/MVPData/sp2.mat')
% yt = DataCell{1};
% Xt = DataCell{2};
% InfoCell = DataCell{3}; 
% nFactors = length(InfoCell); 
% 
% [K,T] = size(yt);
% t= 159;
% Kt = K*t;
% yttrain = yt(:,1:t);
% Xttrain = Xt(1:Kt,:);
% 
% 
% 
% Sims=1000;
% bn = 100;
% cg = 0;
% initFt = normrnd(0,1,nFactors,t);
% lags = 5;
% R0 = ones(K,1);
% g0 = zeros(1,lags);
% % G0 = .5
% G0=diag(fliplr(.5.^(0:lags-1)));
% b0= 0;
% B0 =10;
% a0 = .5;
% A0= 1;
% s0 = 6;
% S0 = 6;
% v0 = 6;
% r0 = 6;
% 
% estml = 1;
% [Output] =GeneralMvProbit(yttrain, Xttrain, Sims, bn, cg, estml, b0, B0, g0, G0, a0, A0,...
%     initFt, InfoCell);
% 
% storeBeta = Output{1};
% storeFt= Output{2};
% storeSt= Output{3};
% storeOm = Output{4};
% % summary2 = Output{6};
% 
% mubeta = mean(storeBeta,2);
% Fhat = mean(storeFt,3);

% load('/home/precision/CodeProjects/MATLAB/MyToolbox/MV_Probit/MVPData/sp3.mat')
% yt = DataCell{1};
% Xt = DataCell{2};
% InfoCell = DataCell{3}; 
% nFactors = length(InfoCell); 
% 
% [K,T] = size(yt);
% t= 159;
% Kt = K*t;
% yttrain = yt(:,1:t);
% Xttrain = Xt(1:Kt,:);
% 
% 
% 
% Sims=1000;
% bn = 100;
% cg = 0;
% initFt = normrnd(0,1,nFactors,t);
% lags = 5;
% R0 = ones(K,1);
% g0 = zeros(1,lags);
% % G0 = .5
% G0=diag(fliplr(.5.^(0:lags-1)));
% b0= 0;
% B0 =10;
% a0 = .5;
% A0= 1;
% s0 = 6;
% S0 = 6;
% v0 = 6;
% r0 = 6;
% 
% estml = 1;
% [Output] =GeneralMvProbit(yttrain, Xttrain, Sims, bn, cg, estml, b0, B0, g0, G0, a0, A0,...
%     initFt, InfoCell);
% 
% storeBeta = Output{1};
% storeFt= Output{2};
% storeSt= Output{3};
% storeOm = Output{4};
% % summary2 = Output{6};
% 
% mubeta = mean(storeBeta,2);
% Fhat = mean(storeFt,3);


% load('/home/precision/CodeProjects/MATLAB/MyToolbox/MV_Probit/MVPData/sp4.mat')
% yt = DataCell{1};
% Xt = DataCell{2};
% InfoCell = DataCell{3}; 
% nFactors = length(InfoCell); 
% 
% [K,T] = size(yt);
% t= 159;
% Kt = K*t;
% yttrain = yt(:,1:t);
% Xttrain = Xt(1:Kt,:);
% 
% 
% 
% Sims=1000;
% bn = 100;
% cg = 0;
% initFt = normrnd(0,1,nFactors,t);
% lags = 5;
% R0 = ones(K,1);
% g0 = zeros(1,lags);
% % G0 = .5
% G0=diag(fliplr(.5.^(0:lags-1)));
% b0= 0;
% B0 =10;
% a0 = .5;
% A0= 10;
% s0 = 6;
% S0 = 6;
% v0 = 6;
% r0 = 6;
% 
% estml = 1;
% [Output] =GeneralMvProbit(yttrain, Xttrain, Sims, bn, cg, estml, b0, B0, g0, G0, a0, A0,...
%     initFt, InfoCell);
% 
% storeBeta = Output{1};
% storeFt= Output{2};
% storeSt= Output{3};
% storeOm = Output{4};
% % summary2 = Output{6};
% 
% mubeta = mean(storeBeta,2);
% Fhat = mean(storeFt,3);