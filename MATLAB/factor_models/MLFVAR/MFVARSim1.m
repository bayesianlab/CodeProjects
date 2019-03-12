function [] = MFVARSim1()

SPC = 2:12;
Reps = length(SPC);
CountriesInRegion = 3;
Regions = 3;
Countries = CountriesInRegion*Regions;
nFactors = 1+Regions+Countries;
R2 = zeros(Reps, nFactors);
T = 50;
Sims = 5000;
burnin =1000;
dirname = '~/CodeProjects/MATLAB/factor_models/MLFVAR/Res1/';
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
    
    initobsmodel = unifrnd(0,1,K,3);
    initStateTransitions = ones(nFactors,1).*.5;
    initFactor = normrnd(0,1,nFactors,T);
    ReducedRuns = 3;
    [sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
         sumObsVariance, sumObsVariance2] = ...
        MultDyFacVarSimVersion(yt,InfoCell, Sims, burnin, ReducedRuns,  initFactor, initobsmodel, ...
        initStateTransitions,v0,r0);
    
    fitted =  (1./sum(sumFt.^2,2)).*sum((sumFt.*Factor),2).* sumFt;
    SST = sum((Factor - mean(Factor,2)).^2,2);
    SSR = sum((Factor - fitted).^2,2) ;
    R2(s,:) = (1-(SSR./SST))';
    fname = createDateString('SPC_RepResults_');
    save([dirname,fname])
end

end

