clear;clc;
% DataCell = SimDataMLF(100, 1, 1,10);
% save('simdata', 'DataCell')
% RunHdfvar(100, 20, 'BigKow', 'kowz_notcentered.mat', 'TestDir')
% RunHdfvar(20, 10, 'BigKow', 'kowz_notcentered_resurrection.mat', 'TestDir')
% RunHdfvar(30,  10, '', 'simdata.mat', 'TestDir')
% RunHdfvar(20,  10, 'TestData', 'simdata.mat', 'TestDir')
% RunBaseline(60,10,'BigKow/kowz_kose.mat', 'TestDir')
MLFtimebreaks(10,200,100)
load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/TimeBreakSimData/totaltime.mat')
yt = DataCell{1,1};
Xt = DataCell{1,2};
[K,~]= size(yt);
yt1 = yt(:,1:100);
Xt1 = Xt(1:K*100,:);
[K,T] = size(yt1);
InfoCell = DataCell{1,3};
levels = size(InfoCell,2);
nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
v0=6;
r0 =10;
s0 = 6;
d0 = 10;
obsPrecision = ones(K,1);
initStateTransitions = .1.*ones(nFactors,1);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
initobsmodel = .1.*ones(K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt1(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T), obsPrecision);
initFactor = reshape(vecFt, nFactors,T);
identification = 2;
%%%%%%%%%%%%
%%%%%%%%%%%%
%DONT FORGET TO TURN THIS ON!!!!!!!!!
%%%%%%%%%%%%
%%%%%%%%%%%%
estML = 1; %%%%%
%%%%%%%%%%%%
%%%%%%%%%%%%
Sims = 90;
burnin=10;
[storeFt, storeVAR, storeOM, storeStateTransitions,...
    storeObsPrecision, storeFactorVar,varianceDecomp, ml1] = Hdfvar(yt1, Xt1,  InfoCell, Sims,...
    burnin, initFactor,  initobsmodel, initStateTransitions, v0, r0, s0, d0, identification, estML, 'TBTEST');

yt2 = yt(:,101:200);
Xt2 = Xt((K*100 + 1):end,:);
[K,T] = size(yt1);
InfoCell = DataCell{1,3};
[~, dimX] = size(Xt1);
levels = size(InfoCell,2);
nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
v0=6;
r0 =10;
s0 = 6;
d0 = 10;
obsPrecision = ones(K,1);
initStateTransitions = .1.*ones(nFactors,1);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
initobsmodel = .1.*ones(K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt1(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T), obsPrecision);
initFactor = reshape(vecFt, nFactors,T);
identification = 2;
%%%%%%%%%%%%
%%%%%%%%%%%%
%DONT FORGET TO TURN THIS ON!!!!!!!!!
%%%%%%%%%%%%
%%%%%%%%%%%%
estML = 1; %%%%%%
%%%%%%%%%%%%
%%%%%%%%%%%%

[storeFt, storeVAR, storeOM, storeStateTransitions,...
    storeObsPrecision, storeFactorVar,varianceDecomp, ml2] = Hdfvar(yt2, Xt2,  InfoCell, Sims,...
    burnin, initFactor,  initobsmodel, initStateTransitions, v0, r0, s0, d0, identification, estML, 'TBTEST');


[K,T] = size(yt);
InfoCell = DataCell{1,3};
[~, dimX] = size(Xt1);
levels = size(InfoCell,2);
nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
v0=6;
r0 =10;
s0 = 6;
d0 = 10;
obsPrecision = ones(K,1);
initStateTransitions = .1.*ones(nFactors,1);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
initobsmodel = .1.*ones(K,levels);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T), obsPrecision);
initFactor = reshape(vecFt, nFactors,T);
identification = 2;
%%%%%%%%%%%%
%%%%%%%%%%%%
%DONT FORGET TO TURN THIS ON!!!!!!!!!
%%%%%%%%%%%%
%%%%%%%%%%%%
estML = 1; %%%%%%
%%%%%%%%%%%%
%%%%%%%%%%%%

[storeFt, storeVAR, storeOM, storeStateTransitions,...
    storeObsPrecision, storeFactorVar,varianceDecomp, ml] = Hdfvar(yt, Xt,  InfoCell, Sims,...
    burnin, initFactor,  initobsmodel, initStateTransitions, v0, r0, s0, d0, identification, estML, 'TBTEST');

A=ml1+ml2
B=ml
A>B