% T=100;
% lags =3;
% % When making gamma,
% % the first element reaches back to the first time period, so
% % remember that the small state transition will appear in the first
% % columns.
% [yt,Xt, InfoCell, Factors, gammas, betas, A, fvar] = GenerateSimData([20], lags, T);
% [K,T] =size(yt)
% levels= length(InfoCell)
% nFactors=size(gammas,1);
% [~, dimX] = size(Xt);
% v0= 6;
% r0 = 4;
% s0 = 6;
% d0 =  20;
% a0 = 1;
% A0inv = 1;
% g0 = zeros(1,lags);
% G0=diag(fliplr(.5.^(0:lags-1)));
% [Ey, Vy]=invGammaMoments(.5*v0, .5*r0);
% [Ey, Vy] =invGammaMoments(.5*s0, .5*d0);
% beta0 = zeros(dimX,K);
% B0inv = .01.*eye(dimX);
% Sims = 100;
% burnin = 10;
% initFactor = Factors;
% initStateTransitions = gammas;
% initObsPrecision = ones(K,1);
% initFactorVar = ones(nFactors,1);
% initobsmodel = A;
% identification=2;
% estML=1;
% [storeFt, storeVAR, storeOM, storeStateTransitions,...
%     storeObsPrecision, storeFactorVar,varianceDecomp, ml] = Hdfvar(yt, Xt,  InfoCell, Sims,...
%     burnin, initFactor,  initobsmodel, initStateTransitions, initObsPrecision, initFactorVar,...
%     beta0, B0inv, v0, r0, s0, d0, a0, A0inv, g0, G0, identification, estML, 'Tests');
% EstimatedVAR = mean(storeVAR,3)';
% Actual = betas;
% table(round(EstimatedVAR,3), Actual)
% EstimatedOM = round(mean(storeOM,3),2);
% Actual = A;
% table(EstimatedOM, Actual)
% EstimatedST = mean(storeStateTransitions,3);
% Actual = gammas;
% table(round(EstimatedST,3), Actual)
% EstimatedObsVar = round(1./mean(storeObsPrecision,2),3);
% Actual = ones(K,1);
% table(EstimatedObsVar, Actual)
% EstFv = round(mean(storeFactorVar,2),3);
% Actual = fvar;
% table(EstFv, Actual)
% vd = round(varianceDecomp,3);
% table(vd)


yt = datastockunempinds{:,2:end};
Xt = datastockunempindsS1{:,2:end};
yt = yt';
[K,T] = size(yt);
Xt = kron(Xt, ones(K,1));
Xt = [ones(K*T,1), Xt];

