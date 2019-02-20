function [] = MFVARSim2()

CR = [3,5,7,9,11];
Reps = length(CR);
SeriesPerCountry =5;
Regions = 3;
R2 = zeros(Reps, Regions + 1);

Sims = 5;
burnin =1;
T = 75;

dirname = '~/CodeProjects/MATLAB/factor_models/MLFVAR/Res1/';
mkdir(dirname)
for s = 1:Reps
    rng(1101)
    CountriesInRegion = CR(s);
    Countries = CountriesInRegion*Regions;
    nFactors = 1+Regions+Countries;
    
    beta = ones(1,SeriesPerCountry+1).*.4;
    gamma = unifrnd(0,.8, 1, 1+Regions+Countries,1);
    K = SeriesPerCountry*CountriesInRegion*Regions;
    [DataCell] = ...
        MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, gamma);
    
    yt = DataCell{1,1};
    Xt = DataCell{1,2};
    Factor = DataCell{1,3};
    InfoCell = DataCell{1,4};
    SeriesPerCountry = InfoCell{1,3};
    Countries = length(InfoCell{1,1});
    Regions = size(InfoCell{1,2},1);
    nFactors = 1 + Regions + Countries;
    v0=3;
    r0 =5;
    initobsmodel = unifrnd(0,1,K,3);
    initStateTransitions = ones(nFactors,1).*.5;
    initBeta = ones(size(Xt,2),1);
    wb = 1;
    ReducedRuns = 3;
    [sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
        sumBeta, sumBeta2, sumObsVariance, sumObsVariance2] = ...
        MultDyFacVarSimVersion(yt, Xt,InfoCell, Sims, burnin, ReducedRuns, initBeta, initobsmodel, ...
        initStateTransitions,v0,r0, wb);
    
    fitted =  (1./sum(sumFt.^2,2)).*sum((sumFt.*Factor),2).* sumFt;
    SST = sum((Factor - mean(Factor,2)).^2,2);
    SSR = sum((Factor - fitted).^2,2) ;
    r2 = (1-(SSR./SST))';
    R2(s,:) = r2(1:Regions+1);
    fname = createDateString('CR_RepResults_');
    save([dirname,fname])
end

end

