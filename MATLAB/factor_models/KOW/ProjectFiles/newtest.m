clear;clc;
rng(145)
CountriesInRegion = 1;
SeriesPerCountry = 10;
Regions = 1;
T = 100;
beta = ones(1,SeriesPerCountry+1).*.4;
G = [.5, .8, .4]';
gamma = ones(Regions + CountriesInRegion*Regions + 1, 1).*.3;
K = SeriesPerCountry*CountriesInRegion*Regions;
[yt, Xt, Factor,InfoMat, beta] = ...
    MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);



Countries = CountriesInRegion*Regions;

nFactors = 1 + Regions + Countries;
v0=5;
r0 =10;
Sims = 30;
burnin =1;
initobsmodel = [.4,.8,.4].*ones(K,3);
initStateTransitions = ones(nFactors,1).*.3;
[sumFt, sumFt2,som] = MultDyFacVar(yt, Xt,InfoMat, SeriesPerCountry, Sims, burnin, initobsmodel, ...
     initStateTransitions,v0,r0);

 figure(1)
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
% ydemut = reshape(yt(:) -Xt*beta,K,T)
% 

% AproptoLL(initobsmodel(:,3), yt, ones(1,K), eye(K), ones(K,1), Factor(1,:), kowStatePrecision(initStateTransitions(1),1,T))

% AproptoLLLevel3(initobsmodel(2:end,3), yt, ones(1,K-1), eye(K-1), ones(K,1), Factor(1,:), kowStatePrecision(initStateTransitions(1),1,T))
% kowRatioLL(yt,initobsmodel(:,3),  ones(1,K), eye(K), ones(K,1), Factor(1,:), kowStatePrecision(initStateTransitions(1),1,T))