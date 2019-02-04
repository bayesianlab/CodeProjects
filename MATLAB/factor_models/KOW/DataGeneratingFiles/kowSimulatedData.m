clear;clc;
% Dimension and setup
rng(130)
T = 200;
Gsim = [0, 0 , .5];

SeriesPerCountry = 10;
betaSim = ones(1,SeriesPerCountry+1).*.2;

Regions = 1;
CountriesInRegion = 1;
g = ones(1,1 + Regions + (CountriesInRegion*Regions)).*.5;
K = Regions*CountriesInRegion*SeriesPerCountry;
Countries = Regions*CountriesInRegion;
[yt, Xt, Factor, RegionIndices,CountriesThatStartRegions, betaTrue ] = ...
    kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, betaSim, Gsim, g);
save('longt')
% clear;
% rng(106)
% T = 100;
% Gsim = [.3, .5, .3];
% gamma = .3;
% SeriesPerCountry = 3;
% betaSim = [.3, -.5, .25];
% Regions = 2;
% CountriesInRegion = 3;
% Countries = Regions*CountriesInRegion;
% K = Regions*CountriesInRegion*SeriesPerCountry;
% mu = ones(Countries*SeriesPerCountry, 1).* -.5;
% [yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
%     kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, betaSim, Gsim, gamma);
% save('onehundredt')
% clear;
% rng(105)
% T = 75;
% Gsim = [0, 0, .3];
% gamma = .3;
% SeriesPerCountry = 3;
% betaSim = [.3, -.5, .25];
% Regions = 2;
% CountriesInRegion = 3;
% Countries = Regions*CountriesInRegion;
% mu = ones(Countries*SeriesPerCountry, 1).* -.5;
% K = Regions*CountriesInRegion*SeriesPerCountry;
% [yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
%     kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, betaSim, Gsim, gamma);
% save('smallt')
% clear;
% load('kowar1.mat')
% CountriesThatStartRegions = [1,4,6,24,42,49,55, -1];
% RegionIndices = [1,9;10,15;16,69;70,123;124,144;145,162;163,180];
% Countries = 60;
% SeriesPerCountry = 3;
% blocks = 36;
% save('kowdataJan7')
% clear

