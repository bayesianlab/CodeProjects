
clear;clc;
% rng(121)
% SeriesPerCountry=1;
% CountriesInRegion = 10;
% Regions = 2;
% Countries = CountriesInRegion*Regions;
% T = 115;
% beta = ones(1,SeriesPerCountry+1).*.4;
% gamma = unifrnd(0,.8, 1, 1+Regions+Countries,1);
% K = SeriesPerCountry*CountriesInRegion*Regions;
% [DataCell] = ...
%     MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, gamma);

load('Housing.mat')
yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
Factor = DataCell{1,4};
Gamma = DataCell{1,6};
Gt = DataCell{1,7};

[K,T] = size(yt);
[~, dimX] = size(Xt);
sectorInfo = cellfun(@(x)size(x,1), InfoCell);
Regions = sectorInfo(2);

levels = size(InfoCell,2);

nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
v0=3;
r0 =5;
s0 = 3;
d0 = 5;
Sims = 20;
burnin = 10;
ReducedRuns = 3;
initBeta = ones(dimX,1);
obsPrecision = ones(K,1);
initobsmodel = .1.*ones(K,levels);
initStateTransitions = ones(nFactors,1).*.1;
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions),1,T), obsPrecision);
Ft = reshape(vecFt, nFactors,T);
initFactor = Ft;
identification = 2;
% Simulation Version 
% 

% initobsmodel = zeros(K,3);
% initobsmodel = .05.*[ones(K,1), ones(K,1), ones(K,1)];
% initobsmodel = unifrnd(0,1,K,3);
% initobsmodel = [zeros(K,1), zeros(K,1), .5.*ones(K,1)];


% initStateTransitions = DataCell{1,6}';
% 

% % 
% % 
% [sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
%     sumObsVariance, sumObsVariance2] = ...
%     MultDyFacVarSimVersion(yt, InfoCell, Sims, burnin,...
%     ReducedRuns,  initFactor, initobsmodel, initStateTransitions,v0,r0, s0,d0, 2);
% plotFt(Factor, sumFt, sumFt2, InfoCell)




% Real Data Version
[sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
    sumObsVariance, sumObsVariance2, sumFactorVar, sumFactorVar2] = ...
    MultDyFacVar(yt, Xt, InfoCell, Sims, burnin,...
    ReducedRuns,  initFactor, initBeta, initobsmodel, initStateTransitions,v0,r0, s0,d0, identification);
% xaxis = 1962:2014;

plotSectorFactor(sumFt(1,:), sumFt2(1,:), 1:108)
% plotSectorFactor(sumFt(2,:), sumFt2(2,:), xaxis)
% plotSectorFactor(sumFt(3,:), sumFt2(3,:), xaxis)
% plotSectorFactor(sumFt(9,:), sumFt2(9,:), xaxis)
% plotSectorFactor(sumFt(10,:), sumFt2(10,:), xaxis)
% plotSectorFactor(sumFt(11,:), sumFt2(11,:), xaxis)
% 

% 
% fitted =  (1./sum(sumFt.^2,2)).*sum((sumFt.*Factor),2).* sumFt;
% SST = sum((Factor - mean(Factor,2)).^2,2);
% SSR = sum((Factor - fitted).^2,2) ;
% R2 = (1-(SSR./SST))'
% disp('Mean Obs. Model')
% disp(mean(mean(sumOM,3),1))
% disp('Mean State Trans. l')
% disp(sumST')
% Gt
% sumOM
% 
% Gamma
% sumST

% rng(9)
% om = [.5;.5;.5];
% yt = normrnd(0,1,3,10);
% p1 = ones(1,3);
% p2 = eye(3);
% f = normrnd(0,1,1,10);
% fp = eye(10);
% 
% AproptoLL(om, yt, p1, p2, p1',f,fp)
% 
% om = [.5;.5];
% p1 = ones(1,2);
% p2 = eye(2);
% pre = ones(3,1)
% LLRestrict(om, yt, p1, p2, pre,f,fp)



