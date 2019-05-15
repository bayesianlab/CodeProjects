%% Spatial model
%Spatial Version
clear;clc;
T = 100;
SeriesPerY =3;
gridX = 3;
squaresSampled= 4;
ploton= 1;
levels = 2;
nearest_neighbor = 1;
euclidean_distance = 2;
parama = 5;
DataCell = SpatialMLFdata(SeriesPerY, gridX,...
    squaresSampled, ploton, levels, T, parama, euclidean_distance);

yt = DataCell{1,1};
size(yt)
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
LocationCorrelation = DataCell{1,4};
Factor = DataCell{1,5};
p = size(LocationCorrelation,1);
zp = zeros(1,p);
zpp = zp;
zp(1) = 1;
zpp(end) = 1;
cutpoints = 1./([zp;zpp]*eig(LocationCorrelation));

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
Sims = 100;
burnin = 10;
ReducedRuns = 3;
initBeta = ones(dimX,1);
obsPrecision = ones(K,1);
initobsmodel = unifrnd(0,1,K, levels);
initStateTransitions = .3.*ones(nFactors,1).*.1;

[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
    kowStatePrecision(diag(initStateTransitions), ones(nFactors,1),T), obsPrecision);
Ft = reshape(vecFt, nFactors,T);
initFactor = Ft;
identification = 2;

[sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
    sumVarianceDecomp2, parama] = ...
    SMDFVAR_SimVersion(yt, InfoCell, euclidean_distance,...
      LocationCorrelation, cutpoints, Sims, burnin,ReducedRuns,...
      initFactor, initobsmodel, initStateTransitions,v0,r0, s0,d0, identification);
  figure
plot(parama)

