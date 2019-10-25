clear;clc;

% DataCell = SimDataMLF(100, 1, 1,6, 1);
% save('simdata', 'DataCell')
% RunHdfvar(3, 1, '', 'simdata.mat', 'TestDir')
% TimeBreakKow(200,  20, '', 'simdata.mat', 'TestDir')
% TimeBreakKow(10,  2, 'BigKow', 'kowz.mat', 'TestDir')
% TimeBreakKow(10, 4, 6, '', 'mpy.mat', 'TestDir')
% TimeBreakKow(10,4,'Unemployment', 'ue_big.mat','TestDir')
% TimeBreakKow(10,4,0,'Unemployment', 'worldue.mat','TestDir')

% load('TestDir/Result_simdata_20_Oct_2019_18_33_53.mat')
% sumft = mean(storeFt,3);
% sig = std(storeFt,[],3);
% up=sumft + 2.*sig;
% down = sumft - 2.*sig;
%
% tf = DataCell{4};
% hold on
% plot(up(1,:),   'r')
% plot(down(1,:),   'r')
% plot(sumft(1,:), 'black')
% DataCell = SimDataMLF(50, 1, 2,3, 1);
% Sims = 10;
% burnin = 5;
% estML = 1;
% yt = DataCell{1,1};
% Xt = DataCell{1,2};
% InfoCell = DataCell{1,3};
% Factor = DataCell{1,4};
% gamma = diag(DataCell{1,6});
% A = DataCell{1,7}
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

% initFactor = Factor;
% 
% identification = 2;
% for u = 1:levels
%     BlockingInfo{u}  = InfoCell{levels};
% end
% 
% 
% 
% [storeFt, storeBeta, storeOM, storeStateTransitions,...
%     storeObsPrecision, storeFactorVar,varianceDecomp, ml] = Hdfvar(yt, Xt,  InfoCell, BlockingInfo,...
%     Sims, burnin, initFactor,  A, gamma, v0, r0, s0, d0, identification, estML, '');
