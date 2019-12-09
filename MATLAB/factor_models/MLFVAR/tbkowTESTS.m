clear;clc;

% DataCell = SimDataMLF(50, 1, 1,9);
% save('simdata', 'DataCell')
RunHdfvar(100, 20, 'BigKow', 'kowz_notcentered.mat', 'TestDir')
% RunHdfvar(100,  10, '', 'simdata.mat', 'TestDir')
% RunHdfvar(20,  10, 'TestData', 'simdata.mat', 'TestDir')

% TimeBreakKow(10,  2, 'BigKow', 'kowz.mat', 'TestDir')
% TimeBreakKow(10, 4, 6, '', 'mpy.mat', 'TestDir')
% TimeBreakKow(10,4,'Unemployment', 'ue_big.mat','TestDir')
% TimeBreakKow(10,4,0,'Unemployment', 'worldue.mat','TestDir')
% RunBaseline(60,10,'BigKow/kowz_kose.mat', 'TestDir')

% load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/TestDir/Result_kowz_kose_02_Dec_2019_16_15_17.mat')
% mus = permute(storeMean, [2,1,3]);
% [r,c,d] = size(storeMean);
% reshapedMean = reshape(mus, r*c,d);
% [R, C]=size(reshapedMean);
% constants = reshapedMean(1:4:R,:);
% factors=CalcIneffFactors(constants(1,:), 30);
% boxplot(factors)
% factors
% DataCell = SimDataMLF(100, 2, 3, 3);
% stateLags = 2;
% Sims = 10;
% burnin = 5;
% estML = 1;
% yt = DataCell{1,1};
% Xt = DataCell{1,2};
% InfoCell = DataCell{1,3};
% Factor = DataCell{1,4};
% gamma = DataCell{1,6};
% A = DataCell{1,7};
% [K,T] = size(yt);
% [~, dimX] = size(Xt);
% levels = size(InfoCell,2);
% nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
% v0=6;
% r0 =10;
% s0 = 6;
% d0 = 10;
% obsPrecision = ones(K,1);
% initStateTransitions = .1.*ones(nFactors,1);
% [Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
% initobsmodel = .1.*ones(K,levels);
% StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T), obsPrecision);
% vecFt = .5.*ones(nFactors*T, 1);
% initFactor = reshape(vecFt, nFactors,T);
% initStateTransitions = unifrnd(0,1,nFactors,stateLags);
% 
% 
% identification = 2;
% for u = 1:levels
%     BlockingInfo{u}  = InfoCell{levels};
% end
% 
% 
% [storeFt, storeBeta, storeOM, storeStateTransitions,...
%     storeObsPrecision, storeFactorVar,varianceDecomp, ml] = Hdfvar(yt, Xt,  InfoCell, BlockingInfo,...
%     Sims, burnin, initFactor,  A, gamma, v0, r0, s0, d0, identification, estML, '');
% gamma
% mean(storeStateTransitions,3)
% sumFt = mean(storeFt,3)
% hold on
% plot(Factor(1,:))
% plot(sumFt(1,:))
