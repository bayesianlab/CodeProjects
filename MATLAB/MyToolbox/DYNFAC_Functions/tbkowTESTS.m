clear;clc;


% DataCell = SimDataMLF(100, 1,1,15);
% save('simdata', 'DataCell')
% rng(1)
% RunHdfvar( 20, 2, 1, '/home/precision/CodeProjects/MATLAB/MatlabReadyData/BigKow/RegionTests', 'country_only.mat','NM_ML', '~/CodeProjects/MATLAB/factor_models/MLFVAR/TestDir')
RunBaseline(20, 2, 1, 0, 1, 1, '/home/precision/CodeProjects/MATLAB/MatlabReadyData/BigKow', 'constant_std.mat', 'TEST', '~/CodeProjects/MATLAB/factor_models/MLFVAR/TestDir')




% clear;
% 
% ModuleTests()



% [P0] = initCovar(gamma, 1) ;
% Ki = FactorPrecision(gamma, P0, 1, T);
% Lk = chol(Ki,'lower')\eye(T);
% F = Lk'*normrnd(0,1,T,1);
% Xt = normrnd(0,1,T*K,1);
% beta = ones(1,1);
% Xbeta = Xt*beta;
% A = ones(K,1);
% AF = A*F';
% yt = reshape(Xbeta + AF(:) + normrnd(0,1,T*K,1), K,T);
%
%
% InfoCell = {[1,K]}
% [K,T] = size(yt);
% [~, dimX] = size(Xt);
% levels = size(InfoCell,2);
% nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
% lagState=1;
% v0= 6
% r0 = 6
% s0 = 6
% d0 = 6
% [Ey, Vy]=invGammaMoments(.5*v0, .5*r0)
% [Ey, Vy] =invGammaMoments(.5*s0, .5*d0)
% a0=0
% A0inv = 5
% g0 = zeros(1,lagState)
% G0 = eye(lagState)
%
% beta0 = [mean(yt,2)'; zeros(dimX-1, K)]
% B0inv = 10.*eye(dimX)
%
%
% Sims = 50;
% burnin = 5;
% initFactor = zeros(1,T);
% initStateTransitions = 0;
% initObsPrecision = ones(10,1);
% initFactorVar = 10;
% initobsmodel = A;
% identification=2;
% estML=0;
% [storeFt, storeVAR, storeOM, storeStateTransitions,...
%     storeObsPrecision, storeFactorVar,varianceDecomp, ml] = Hdfvar(yt, Xt,  InfoCell, Sims,...
%     burnin, initFactor,  initobsmodel, initStateTransitions, initObsPrecision, initFactorVar,...
%     beta0, B0inv, v0, r0, s0, d0, a0,A0inv, g0, G0, identification, estML, 'Tests');
% Fhat = mean(storeFt,3);
% figure
% plot(F)
% hold on
% plot(Fhat)
% fprintf('\nVAR PARAMS\n')
% disp(mean(storeVAR,3))
% fprintf('\n OBS MODEL \n')
% disp(mean(storeOM,3))
% fprintf('\n State Transitions\n')
% disp(mean(storeStateTransitions,3))
% fprintf('\n OBS VARIANCE \n')
% disp(1./mean(storeObsPrecision,2))
% fprintf('\n FACTOR VARIANCE \n')
% disp(mean(storeFactorVar,2))
% fprintf('\n VARIANCE DECOMP\n')
% disp(varianceDecomp)
