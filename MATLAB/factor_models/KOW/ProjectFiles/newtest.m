clear;clc;
rng(145)
CountriesInRegion = 1;
SeriesPerCountry = 3;
Regions = 1;
T = 250;
beta = ones(1,SeriesPerCountry+1).*.4;
G = [.3, .5, .4]';
gamma = ones(Regions + CountriesInRegion*Regions + 1, 1).*.3;
K = SeriesPerCountry*CountriesInRegion*Regions;
[yt, Xt, Factor,InfoMat, beta] = ...
    kowGenSimData(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);



Countries = CountriesInRegion*Regions;
InfoMat
nFactors = 1 + Regions + Countries;
v0=5;
r0 =10;
Sims = 20;
burnin =1;
initobsmodel = [1,1,1].*ones(K,3);
initStateTransitions = ones(nFactors,1).*.3;
[sumFt, sumFt2] = MultDyFacVar(yt, Xt,InfoMat, SeriesPerCountry, Sims, burnin, initobsmodel, ...
     initStateTransitions,v0,r0);
 
hold on 
plot(Factor(2,:))
plot(sumFt(2,:))

figure(2)
hold on
plot(Factor(2,:))
plot(sumFt(2,:))
% ydemut = reshape(yt(:) -Xt*beta,K,T)
% 
% AproptoLLLevel3(initobsmodel(2:end,1), ydemut, ones(1,K-1), eye(K-1), ones(K,1), Factor(1,:), kowStatePrecision(initStateTransitions(1),1,T))
% kowRatioLL(ydemut(2:end,:),initobsmodel(2:end,1),  ones(1,K-1), eye(K-1), ones(K-1,1), Factor(1,:), kowStatePrecision(initStateTransitions(1),1,T))