clear;clc;
% % DataCell = SimDataMLF(100, 2,2,5);
% % save('simdata', 'DataCell')
RunHdfvar(10, 2, 'BigKow', 'kow_raw.mat', 'TestDir')
% % RunHdfvar(20, 10, 'BigKow', 'kowz_notcentered_resurrection.mat', 'TestDir')
% % RunHdfvar(30,  10, '', 'simdata.mat', 'TestDir')
% % RunHdfvar(20,  10, 'TestData', 'simdata.mat', 'TestDir')
% RunBaseline(5,2,'BigKow/kow_standardized.mat', 'TestDir')

% rng(9)
% T = 200;
% K = 10;
% timebreak = 100;
% MLFtimebreaks(K,T,timebreak)
% load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/TimeBreakSimData/totaltime.mat')
% yt = DataCell{1,1};
% Xt = DataCell{1,2};
% Ft = DataCell{4};
% 
% [K,~]= size(yt);
% yt1 = yt(:,1:timebreak);
% Xt1 = Xt(1:K*timebreak,:);
% [K,T1] = size(yt1);
% InfoCell = DataCell{1,3};
% levels = size(InfoCell,2);
% nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
% v0=6;
% r0 =10;
% s0 = 6;
% d0 = 10;
% obsPrecision = ones(K,1);
% initStateTransitions = .5.*ones(nFactors,1);
% [Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
% initobsmodel = ones(K,levels);
% StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt1(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T1), obsPrecision);
% initFactor = reshape(vecFt, nFactors,T1);
% identification = 2;
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% %DONT FORGET TO TURN THIS ON!!!!!!!!!
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% estML = 1; %%%%%
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% Sims = 150;
% burnin=50;
% [storeFt, storeVAR, storeOM, storeStateTransitions,...
%     storeObsPrecision, storeFactorVar,varianceDecomp, ml1] = Hdfvar(yt1, Xt1,  InfoCell, Sims,...
%     burnin, initFactor,  initobsmodel, initStateTransitions, v0, r0, s0, d0, identification, estML, 'TBTEST');
% 
% yt2 = yt(:,(timebreak+1):end);
% Xt2 = Xt((K*timebreak + 1):end,:);
% [K,T1] = size(yt2);
% InfoCell = DataCell{1,3};
% [~, dimX] = size(Xt1);
% levels = size(InfoCell,2);
% nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
% v0=6;
% r0 =10;
% s0 = 6;
% d0 = 10;
% obsPrecision = ones(K,1);
% initStateTransitions = .1.*ones(nFactors,1);
% [Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
% initobsmodel = ones(K,levels);
% StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt2(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T1), obsPrecision);
% initFactor = reshape(vecFt, nFactors,T1);
% identification = 2;
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% %DONT FORGET TO TURN THIS ON!!!!!!!!!
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% estML = 1; %%%%%%
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% 
% [storeFt, storeVAR, storeOM, storeStateTransitions,...
%     storeObsPrecision, storeFactorVar,varianceDecomp, ml2] = Hdfvar(yt2, Xt2,  InfoCell, Sims,...
%     burnin, initFactor,  initobsmodel, initStateTransitions, v0, r0, s0, d0, identification, estML, 'TBTEST');
% 
% 
% [K,T1] = size(yt);
% InfoCell = DataCell{1,3};
% [~, dimX] = size(Xt1);
% levels = size(InfoCell,2);
% nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
% v0=6;
% r0 =10;
% s0 = 6;
% d0 = 10;
% obsPrecision = ones(K,1);
% initStateTransitions = .5.*ones(nFactors,1);
% [Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
% initobsmodel = ones(K,levels);
% StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T1), obsPrecision);
% initFactor = reshape(vecFt, nFactors,T1);
% identification = 2;
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% %DONT FORGET TO TURN THIS ON!!!!!!!!!
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% estML = 1; %%%%%%
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% 
% [storeFt, storeVAR, storeOM, storeStateTransitions,...
%     storeObsPrecision, storeFactorVar,varianceDecomp, ml] = Hdfvar(yt, Xt,  InfoCell, Sims,...
%     burnin, initFactor,  initobsmodel, initStateTransitions, v0, r0, s0, d0, identification, estML, 'TBTEST');
% 
% A=ml1+ml2
% B=ml
% A-B
% disp(A>B)