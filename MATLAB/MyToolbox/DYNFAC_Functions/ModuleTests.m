function [] = ModuleTests()
clear;clc;
TestDGP=0;
Test3=0;
Test4 = 1;

% rng(88)
% 
% 
% T=50;
% lags =1;
% [yt,Xt, InfoCell, Factors, gammas, betas, A, fvar] = GenerateSimData([10], lags, T);
% [K,T] =size(yt)
% levels= length(InfoCell)
% nFactors=size(gammas,1);
% initFactor = normrnd(0,1,nFactors,T);

if TestDGP == 1
    clc
    fprintf('Test DGP Funcitons\n')
    T=100;
    Gamma= [.2];
    sigma2=1;
    [F, H, Rs, vt] =StateSpaceDGP(Gamma, sigma2, T);
    check=( H*F(:))- Rs*vt(:);
    checksum = sum(check);
    if abs(checksum) < 1e-10
        fprintf('\n\tDGP TEST 1, HF=v: TRUE \n')
    end
    
    T=100;
    g1 = [.2,0; 0,.3];
    g2 = [.1,0; 0, .2];
    g3 = [.01, 0; 0,.02];
    g4 = [.01,0; 0, .002];
    Gamma = [g1,g2,g3,g4];
    
    sigma2=[1;1];
    [F, H, Rs, vt] =StateSpaceDGP(Gamma, sigma2, T);
    check=(Rs \ H*F(:))-vt(:);
    checksum = sum(check);
    if abs(checksum) < 1e-10
        fprintf('\n\tDGP TEST 2, HF=v: TRUE \n')
    end
end




%     rng(1)
% When making gamma,
% the first element reaches back to the first time period, so
% remember that the small state transition will appear in the first
% columns.



% [~, dimX] = size(Xt);
% v0= 10;
% r0 = 10;
% s0 = 10;
% d0 =  10;
% a0 = 1;
% A0inv = 1;
% [Ey, Vy]=invGammaMoments(.5*v0, .5*r0);
% [Ey, Vy] =invGammaMoments(.5*s0, .5*d0);
% 
% g0 = zeros(1,lags);
% G0=diag(fliplr(.5.^(0:lags-1)));
% beta0 = 1;
% B0inv = 1;
% 
% 
% Sims = 800;
% burnin = 100;
% initFactor = normrnd(0,1,nFactors,T);
% initStateTransitions = zeros(nFactors,lags);
% %     initFactor = Factors;
% %     initStateTransitions = gammas;
% initStateTransitions = zeros(nFactors,lags);
% initObsPrecision = ones(K,1);
% initFactorVar = ones(nFactors,1);
% initobsmodel = zeros(K,levels);
% identification=2;
% estML=1;
% tau = ones(1,nFactors);
% [storeFt, storeVAR, storeOM, storeStateTransitions,...
%     storeObsPrecision, storeFactorVar,varianceDecomp, ml, summary] = Hdfvar(yt, Xt,  InfoCell, Sims,...
%     burnin, initFactor,  initobsmodel, initStateTransitions, initObsPrecision, initFactorVar,...
%     beta0, B0inv, v0, r0, s0, d0, a0, A0inv, g0, G0, tau, identification, estML, 'Tests');
% 
% Actual = betas
% estVAR = round( mean(storeVAR,3),3)
% table(estVAR(:), Actual)
% EstOM = round(mean(storeOM,3),2);
% Actual = A;
% table(EstOM, Actual)
% st = round(mean(storeStateTransitions,3),3);
% Actual = gammas;
% table(st, Actual)
% ov = round(1./mean(storeObsPrecision,2),3);
% Actual = ones(K,1);
% table(ov, Actual)
% EstFv = round(mean(storeFactorVar,2),3);
% Actual = fvar;
% table(EstFv, Actual)
% vd = round(varianceDecomp,3);
% table(vd)
% 
% Fhat = mean(storeFt,3);
% [Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
% Som = makeStateObsModel(EstOM, Identities, 0);
% 
% yhat1= reshape(surForm(Xt, K) * estVAR', K,T)+Som*Fhat;
% 
% 
% 
% 
% lagOM=1;
% lagFac= lagOM;
% 
% [K,T] =size(yt)
% levels= length(InfoCell)
% nFactors=size(gammas,1);
% [~, dimX] = size(Xt);
% v0= 10;
% r0 = 10;
% s0 = 10;
% d0 =  10;
% a0 = 1;
% A0inv = 1;
% [Ey, Vy]=invGammaMoments(.5*v0, .5*r0);
% [Ey, Vy] =invGammaMoments(.5*s0, .5*d0);
% 
% g0 = zeros(1,lagOM);
% G0=diag(fliplr(.5.^(0:lagOM-1)));
% beta0 = 1;
% B0inv = 1;
% 
% 
% 
% %     initFactor = Factors;
% initFactor = normrnd(0,1,nFactors,T);
% %     initStateTransitions = gammas;
% idelta = zeros(K,lagOM);
% igamma=zeros(nFactors, lagFac);
% iBeta = [zeros(K,dimX), zeros(K,levels)];
% 
% estML=1;
% arerrors = 0;
% [storeMeans, storeLoadings, storeOmArTerms,...
%     storeStateArTerms, storeFt, storeObsV, storeFactorVariance,...
%     varianceDecomp, ML, vd, summary2] = Baseline(InfoCell,yt,Xt, initFactor, iBeta,...
%     idelta, igamma, beta0, B0inv, v0, r0, s0, d0, g0, G0, Sims, burnin, arerrors, estML);
% 
% 
% names = {'LL', 'prior_beta',  'Fpriorstar', 'priorST', 'priorObsVariance', 'priorFactorVar', 'priorAstar', 'piFt', 'piBeta', 'piA' , 'piST', 'piObsVariance', 'piFactorVariance'};
% table(names', summary)
% names2 = {'LL', 'priorBeta', 'Fpriorstar', 'priorFactorAR', 'priorVar', 'priorFactorVar', 'piFactor', 'piBeta',  'piFactorAR', 'piOmVar', 'piFV'};
% table(names2', summary2)
% sum(summary2)
% 
% mu_baseline = mean(storeMeans,3);
% ft_baseline = mean(storeFt,3);
% obsv_baseline = mean(storeObsV,2);
% fv_baseline = mean(storeFactorVariance,2);
% ar_baseline = mean(storeStateArTerms,3);
% load_baseline = mean(storeLoadings,3);
% yhat2 = reshape(surForm(Xt, K)*mu_baseline(:),K,T) + makeStateObsModel(load_baseline, Identities,0)*ft_baseline;
% 
% 
% table(ML, ml)
% table(mu_baseline, estVAR')
% table(obsv_baseline, ov)
% table(fv_baseline, EstFv)
% table(ar_baseline, st)
% table(load_baseline, EstOM)
% 
% 
% % plot(yhat1(1,:))
% % hold on
% % plot(yhat2(1,:))
% % plot(yt(1,:))


rng(16)
g = [.1,.3];
lags = length(g) ;
T = 50;
K = 40;
P0 = initCovar(g, 1);
P = FactorPrecision(g, P0, 1, T);
LPinv = chol(P,'lower')\eye(T);
f1 = (LPinv'*normrnd(0,1,T,1))';
f2 = (LPinv'*normrnd(0,1,T,1))';

A = unifrnd(0,1,K,2);
A= tril(A);
[R,C] = size(A);

for c = 1:C
    for b = 1:C
        if b == c
            A(c,c) = 1;
        end
    end
end

Xt = normrnd(0,1,K*T,1);
b = zeros(K,1);
SurX = surForm(Xt,K);


yt = reshape(SurX*b,K,T) + A(:,1)*[f1]  + A(:,2)*f2 + normrnd(0,1,K,T);
g = [g;g];
InfoCell{1} = [1,K];
InfoCell{2} = [2,K];

[K,T] =size(yt)
levels= length(InfoCell);
nFactors=size(g,1);
initFactor = normrnd(0,1,nFactors,T);
[~, dimX] = size(Xt);
v0= 6;
r0 = 10;
s0 = 6;
d0 = 10;
a0 = .5;
A0inv = .01;
[Ey, Vy]=invGammaMoments(.5*v0, .5*r0);
[Ey, Vy] =invGammaMoments(.5*s0, .5*d0)

g0 = zeros(1,lags);
G0=diag(fliplr(.5.^(0:lags-1)));
beta0 = 1;
B0inv = .1;


Sims = 50;
burnin = 10;
initFactor = normrnd(0,1,nFactors,T);
% initFactor = [f1;f2];
initStateTransitions = zeros(nFactors,lags);
%     initFactor = Factors;
%     initStateTransitions = gammas;
initStateTransitions = [.1,.3].*ones(nFactors,lags);
initObsPrecision = ones(K,1);
initFactorVar = ones(nFactors,1);
initobsmodel = ones(K,levels);
% initobsmodel(1,2) = 0;
identification=2;
estML=0;
% tau = ones(1,nFactors);
tau =ones(nFactors,1);
[storeFt, storeVAR, storeOM, storeStateTransitions,...
    storeObsPrecision, storeFactorVar,varianceDecomp, ml, summary] = Hdfvar(yt, Xt,  InfoCell, Sims,...
    burnin, initFactor,  initobsmodel, initStateTransitions, initObsPrecision, initFactorVar,...
    beta0, B0inv, v0, r0, s0, d0, a0, A0inv, g0, G0, tau, identification, estML, 'Tests');

Fhat = mean(storeFt,3);


bhat = mean(storeVAR,3)
Ahat = mean(storeOM,3);
[Ahat,A]
mean(storeStateTransitions,3)
ovhat = 1./mean(storeObsPrecision,2)
fvhat = mean(storeFactorVar,2)
yhat = reshape(SurX*bhat(:),K,T) + Ahat*Fhat;


hold on 
plot(f1)
plot(Fhat(1,:))

figure
hold on 
plot(f2)
plot(Fhat(2,:))

% 
% figure
% hold on 
% plot(yt(1,:))
% plot(yhat(1,:))


end
