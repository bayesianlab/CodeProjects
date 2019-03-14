function [] = MFVARSim3()

SeriesPerCountry = 3;
CountriesInRegion = 3;
Regions = 2:8;
Reps = length(Regions);

T = 75;
Sims = 5000;
burnin =1000;
dirname = '~/CodeProjects/MATLAB/factor_models/MLFVAR/Res3/';
mkdir(dirname)
for s = 1:Reps
    fprintf('Repetition number %i\n', s)
    rng(1101)
    R = Regions(s);
    Countries = CountriesInRegion*R;
    nFactors = 1+R+Countries;
    R2 = zeros(Reps, nFactors);
    gamma = unifrnd(.1,.5, 1, 1+R+Countries,1);
    K = SeriesPerCountry*CountriesInRegion*R;
    beta = 0;
    [DataCell] = ...
        MLFdata(T, R, CountriesInRegion,SeriesPerCountry,beta, gamma);
    
    yt = DataCell{1,1};
    InfoCell = DataCell{1,3};
    Factor = DataCell{1,4};    
    nFactors = 1 + R + Countries;
    v0=3;
    r0 =5;
    
    initobsmodel = unifrnd(0,1,K,3);
    initStateTransitions = ones(nFactors,1).*.5;
    initFactor = normrnd(0,1,nFactors,T);
    ReducedRuns = 3;
    [sumFt, sumFt2,sumOM, sumOM2, sumST, sumST2,...
        sumObsVariance, sumObsVariance2] = ...
        MultDyFacVarSimVersion(yt,InfoCell, Sims, burnin, ReducedRuns, initFactor, initobsmodel, ...
        initStateTransitions,v0,r0);
    
    fitted =  (1./sum(sumFt.^2,2)).*sum((sumFt.*Factor),2).* sumFt;
    SST = sum((Factor - mean(Factor,2)).^2,2);
    SSR = sum((Factor - fitted).^2,2) ;
    R2(s,:) = (1-(SSR./SST))';
    fname = createDateString('Reg_RepResults_');
    save([dirname,fname])
end

end

