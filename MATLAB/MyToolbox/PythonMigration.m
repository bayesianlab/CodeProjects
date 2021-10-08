% % clear;clc;
% % yt = importfile('/home/dillon/CodeProjects/CProjects/MultilevelModel/build/yt.csv', 1, 8);
% % Xt = importfile2('/home/dillon/CodeProjects/CProjects/MultilevelModel/build/xt.csv', 1, 80);
% yt = yt1;
% Xt = table2array(xt);
% gammas = [.1,.3;.1,.3];
% 
% InfoCell = { [1,4], [5,8] };
% lags = size(gammas,2);
% 
% [K,T] =size(yt);
% levels= length(InfoCell);
% nFactors=size(gammas,1);
% Factors = zeros(nFactors, T); 
% [~, dimX] = size(Xt);
% 
% v0= 6;
% r0 = 4;
% s0 = 6;
% d0 =  20;
% a0 = 1;
% A0inv = 1;
% g0 = zeros(1,lags);
% % G0=diag(fliplr(.5.^(0:lags-1)));
% G0 = eye(lags) ;
% 
% beta0 = 0;
% B0inv = .01;
% Sims = 10;
% burnin = 10;
% initFactor = Factors;
% initStateTransitions = gammas;
% initObsPrecision = ones(K,1);
% initFactorVar = ones(nFactors,1);
% 
% A = ones(K,nFactors);
% initobsmodel = A;
% identification=2;
% estML=1;
% 
% Xt = Xt(:,1:2);
% [storeFt, storeVAR, storeOM, storeStateTransitions,...
%     storeObsPrecision, storeFactorVar,varianceDecomp, ml] = Hdfvar(yt, Xt,  InfoCell, Sims,...
%     burnin, initFactor,  initobsmodel, initStateTransitions, initObsPrecision, initFactorVar,...
%     beta0, B0inv, v0, r0, s0, d0, a0, A0inv, g0, G0, identification, estML, 'Tests');





% factors = table2array(factors(:,1:2));
% resids = table2array(resids);

% FP = FactorPrecision([.05,.35;.05,.35], eye(2), ones(2,1), 100);
% A = ones(8,2);
% A = .5*A;
% A(1,1) = 1; 
% A(5,2) = 1;
% 
% f= kowUpdateLatent(resids(:), A, FP, ones(8,1))
% f=reshape(f, 2,100);
% hold on 
% plot(factors(:,1))
% plot(f(1,:))

% yt = table2array(yt);

% xt(isnan(xt)) = 0; 
% xt = xt(:, 4:end);
% xt(:,2) = sum(xt(:,2:3),2)
% xt = xt(:,1:2)

% ft0=table2array(ft0);
% ft1=table2array(ft1);
% Factors = [ft0];

lags =1;

[yt, xt, InfoCell, Factors, gammas, betas, A, factorvar, omvar] = GenerateSimData(30, lags, 200);
[K,T] =size(yt);
levels= length(InfoCell);
nFactors=size(gammas,1);
% Factors = zeros(nFactors, T); 
[~, dimX] = size(xt);

v0= 6;
r0 = 8;
s0 = 6;
d0 =  8;
a0 = 1;
A0inv = 1;
g0 = zeros(1,lags);
% G0=diag(fliplr(.5.^(0:lags-1)));
G0 = eye(lags) ;

beta0 = 0;
B0inv = .001;
Sims = 10;
burnin = 1;
initFactor = Factors;
initStateTransitions = gammas;
initObsPrecision = ones(K,1);
initFactorVar = ones(nFactors,1);

A = ones(K,nFactors);
initobsmodel = A;
identification=2;
estML=1;

plot(Factors)
[storeFt, storeVAR, storeOM, storeStateTransitions,...
    storeObsPrecision, storeFactorVar,varianceDecomp, ml] = Hdfvar(yt, xt,  InfoCell, Sims,...
    burnin, initFactor,  initobsmodel, initStateTransitions, initObsPrecision, initFactorVar,...
    beta0, B0inv, v0, r0, s0, d0, a0, A0inv, g0, G0, identification, estML, 'Tests');


