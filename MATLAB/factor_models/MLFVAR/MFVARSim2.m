function [] = MFVARSim2()

CR = 2:12;
Reps = length(CR);
SeriesPerCountry =3;
Regions = 3;
R2 = zeros(Reps, Regions + 1);

Sims = 5;
burnin =1;
T = 50;

dirname = '~/CodeProjects/MATLAB/factor_models/MLFVAR/Res2/';
mkdir(dirname)
for s = 1:Reps
    rng(1101)
    CountriesInRegion = CR(s);
    Countries = CountriesInRegion*Regions;
    nFactors = 1+Regions+Countries;
    
    beta = ones(1,SeriesPerCountry+1).*.4;
    gamma = unifrnd(.1,.5, 1, 1+Regions+Countries,1);
    K = SeriesPerCountry*CountriesInRegion*Regions;
    [DataCell] = ...
        MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, gamma);
    
    yt = DataCell{1,1};
    InfoCell = DataCell{1,3};
    Factor = DataCell{1,4};
    v0=3;
    r0 =5;
    initobsmodel = unifrnd(0,1,K,3);
    initFactor = normrnd(0,1,nFactors,T);
    initStateTransitions = ones(nFactors,1).*.5;
    ReducedRuns = 3;
    [sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
        sumObsVariance, sumObsVariance2] = ...
        MultDyFacVarSimVersion(yt, InfoCell, Sims, burnin, ReducedRuns,  initFactor, initobsmodel, ...
        initStateTransitions,v0,r0);
    
    fitted =  (1./sum(sumFt.^2,2)).*sum((sumFt.*Factor),2).* sumFt;
    SST = sum((Factor - mean(Factor,2)).^2,2);
    SSR = sum((Factor - fitted).^2,2) ;
    r2 = (1-(SSR./SST))';
    R2(s,:) = r2(1:Regions+1);

end
    fname = createDateString('CR_RepResults_');
    save([dirname,fname])
end

