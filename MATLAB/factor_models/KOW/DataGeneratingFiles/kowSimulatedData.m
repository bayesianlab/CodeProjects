clear;clc;
% Dimension and setup
rng(1.6)
T = 500;
Gsim = [.3, .3, .3];
gamma = .3;
SeriesPerCountry = 3;
betaSim = [.3, -.5, .25];
Regions = 2;
CountriesInRegion = 3;
K = Regions*CountriesInRegion*SeriesPerCountry;
Countries = Regions*CountriesInRegion;
mu = ones(Countries*SeriesPerCountry, 1).* -.5;
[yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
    kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, betaSim, Gsim, gamma);
save('longt')
clear;
rng(1.6)
T = 100;
Gsim = [.3, .5, .3];
gamma = .3;
SeriesPerCountry = 3;
betaSim = [.3, -.5, .25];
Regions = 2;
CountriesInRegion = 3;
Countries = Regions*CountriesInRegion;
K = Regions*CountriesInRegion*SeriesPerCountry;
mu = ones(Countries*SeriesPerCountry, 1).* -.5;
[yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
    kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, betaSim, Gsim, gamma);
save('onehundredt')
clear;

T = 75;
Gsim = [.3, .5, .3];
gamma = .3;
SeriesPerCountry = 3;
betaSim = [.3, -.5, .25];
Regions = 2;
CountriesInRegion = 3;
Countries = Regions*CountriesInRegion;
mu = ones(Countries*SeriesPerCountry, 1).* -.5;
K = Regions*CountriesInRegion*SeriesPerCountry;
[yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
    kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, betaSim, Gsim, gamma);
save('smallt')
clear;
% load('kowar1.mat')
% CountriesThatStartRegions = [1,4,6,24,42,49,55, -1];
% RegionIndices = [1,9;10,15;16,69;70,123;124,144;145,162;163,180];
% Countries = 60;
% SeriesPerCountry = 3;
% blocks = 36;
% save('kowdataJan7')
% clear

