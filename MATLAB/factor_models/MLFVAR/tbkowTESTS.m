clear;clc;
rng(65)
% DataCell = SimDataMLF(100, 1,1,15);
% save('simdata', 'DataCell')
% rng(1)
% RunHdfvar(49, 0, '~/CodeProjects/MATLAB/factor_models/MLFVAR/TimeBreakDataKOW', 'TimeEnd15.mat', '~/CodeProjects/MATLAB/factor_models/MLFVAR/TestDir')
% RunHdfvar(10, 5, '~/CodeProjects/MATLAB/factor_models/MLFVAR/BigKow', 'kow_raw.mat', '~/CodeProjects/MATLAB/factor_models/MLFVAR/TestDir')

% % RunHdfvar(20, 10, 'BigKow', 'kowz_notcentered_resurrection.mat', 'TestDir')
% RunHdfvar(30,  10, '', 'simdata.mat', 'TestDir')

RunBaseline(10,1,'BigKow/', 'kowz.mat',...
    '~/CodeProjects/MATLAB/factor_models/MLFVAR/TestDir')

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
% 
% load('simdata.mat')
% yt = DataCell{1,1};
% Xt = DataCell{1,2};
% Ft = DataCell{4};
% 
% [K,T]= size(yt);
% 
% [K,T1] = size(yt);
% InfoCell = DataCell{1,3};
% levels = size(InfoCell,2);
% nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
% v0= .1.*mean(var(yt,[],2));
% r0 =v0;
% s0 = v0;
% d0 = v0;
% obsPrecision = .5.*ones(K,1);
% initStateTransitions = .01.*ones(nFactors,1);
% [Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
% initobsmodel = .1.*ones(K,levels);
% initObsPrecision = 1./var(yt,[],2);
% StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
% vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
%     kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T1), obsPrecision);
% initFactor = reshape(vecFt, nFactors,T1);
% % initFactor = DataCell{4};
% % identification = 2;
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% %DONT FORGET TO TURN THIS ON!!!!!!!!!
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% estML = 0; %%%%%
% %%%%%%%%%%%%
% %%%%%%%%%%%%
% identification=2;
% Sims = 150;
% burnin=50;
% [storeFt, storeVAR, storeOM, storeStateTransitions,...
%     storeObsPrecision, storeFactorVar,varianceDecomp, ml1] = Hdfvar(yt, Xt,  InfoCell, Sims,...
%     burnin, initFactor,  initobsmodel, initStateTransitions, initObsPrecision, v0, r0, s0, d0, identification, estML, 'TBTEST');
% 
% betas = mean(storeVAR,3);
% mu1 = reshape(surForm(Xt, K)*betas(:),K,T);
% mu2 = makeStateObsModel(mean(storeOM,3),Identities,0)*mean(storeFt,3);
% yhat=mu1+mu2;
