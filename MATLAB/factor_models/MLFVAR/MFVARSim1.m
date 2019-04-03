function [] = MFVARSim1()

identification = 2;
SPC = 2:12;
Reps = length(SPC);
CountriesInRegion = 3;
Regions = 3;
Countries = CountriesInRegion*Regions;
nFactors = 1+Regions+Countries;
R2 = zeros(Reps, nFactors);
T = 75;
Sims = 5;
burnin =1;
dirname = '~/CodeProjects/MATLAB/factor_models/MLFVAR/ID2_1/';
mkdir(dirname)
for s = 1:Reps
    fprintf('Repetition number %i\n', s)
    rng(1101)
    SeriesPerCountry =SPC(s);
    beta = ones(1,SeriesPerCountry+1).*.4;
    
    gamma = unifrnd(.1,.5, 1, 1+Regions+Countries,1);
    K = SeriesPerCountry*CountriesInRegion*Regions;
    [DataCell] = ...
        MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, gamma);
    
    yt = DataCell{1,1};
    Xt = DataCell{1,2};
    InfoCell = DataCell{1,3};
    Factor = DataCell{1,4};
    
    nFactors = 1 + Regions + Countries;
    v0=3;
    r0 =5;
    s0 = 3;
    d0 = 5;
    initobsmodel = [.5.*ones(K,1), .5.*ones(K,1), .5.*ones(K,1)];
    initStateTransitions = ones(nFactors,1).*.5;
    obsPrecision = ones(K,1);
    [Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
    StateObsModel = makeStateObsModel(initobsmodel,Identities,0);
    vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, ...
        kowStatePrecision(diag(initStateTransitions),1,T), obsPrecision);
    Ft = reshape(vecFt, nFactors,T);
    initFactor = Ft;
    ReducedRuns = 3;
    [sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
        sumObsVariance, sumObsVariance2] = ...
        MultDyFacVarSimVersion(yt, InfoCell, Sims, burnin,...
        ReducedRuns,  initFactor, initobsmodel, initStateTransitions,v0,r0, s0,d0, identification);
    
    fitted =  (1./sum(sumFt.^2,2)).*sum((sumFt.*Factor),2).* sumFt;
    SST = sum((Factor - mean(Factor,2)).^2,2);
    SSR = sum((Factor - fitted).^2,2) ;
    R2(s,:) = (1-(SSR./SST))';
end
fname = createDateString('SPC_RepResults_');
save([dirname,fname])
end

