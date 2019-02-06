clear;clc;
rng(1101)
CountriesInRegion = 5;
Regions = 10;
Countries = CountriesInRegion*Regions;
SeriesPerCountry =3;

T = 50;
beta = ones(1,SeriesPerCountry+1).*.4;
G = [.7, .3, .4]';
gamma = linspace(.2, .3, 1+Regions+Countries);
K = SeriesPerCountry*CountriesInRegion*Regions;
[yt, Xt, Factor,InfoCell, beta] = ...
    MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);


Countries = CountriesInRegion*Regions;

nFactors = 1 + Regions + Countries;
v0=3;
r0 =5;
Sims = 100;
burnin =10;
initobsmodel = [.2,.2,.2].*ones(K,3);
initStateTransitions = ones(nFactors,1).*.5;
initBeta = beta;

wb = 6;


[sumFt, sumFt2,som] = MultDyFacVar(yt, Xt,InfoCell, SeriesPerCountry, Sims, burnin, initBeta, initobsmodel, ...
     initStateTransitions,v0,r0, wb);

 RegionInfo = InfoCell{1,2};
mean(mean(som,3),1)

hold on
plot(Factor(1,:))
plot(sumFt(1,:))
figure(2)
hold on
plot(Factor(2,:))
plot(sumFt(2,:))
figure(3)
hold on
plot(Factor(3,:))
plot(sumFt(3,:))
%  plotFt(Factor, sumFt, sumFt2, InfoMat)
