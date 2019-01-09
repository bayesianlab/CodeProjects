clear;clc;
% Dimension and setup
rng(1.6)
T = 500;
G = [-.5, -.3, .25];
gamma = .3;
SeriesPerCountry = 3;
betaSim = [.3, -.5, .25];
Regions = 2;
CountriesInRegion = 3;
Countries = Regions*CountriesInRegion;
mu = ones(Countries*SeriesPerCountry, 1).* -.5;
[yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
    kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, betaSim, G, gamma);
save('longt')
clear;
rng(1.6)
T = 100;
G = [-.5, -.3, .25];
gamma = .3;
SeriesPerCountry = 3;
betaSim = [.3, -.5, .25];
Regions = 2;
CountriesInRegion = 3;
Countries = Regions*CountriesInRegion;
mu = ones(Countries*SeriesPerCountry, 1).* -.5;
[yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
    kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, betaSim, G, gamma);
save('onehundredt')
clear;
rng(1.6)
T = 75;
G = [-.5, -.3, .25];
gamma = .3;
SeriesPerCountry = 3;
betaSim = [.3, -.5, .25];
Regions = 2;
CountriesInRegion = 3;
Countries = Regions*CountriesInRegion;
mu = ones(Countries*SeriesPerCountry, 1).* -.5;
[yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
    kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, betaSim, G, gamma);
save('smallt')
clear;
load('kowar1.mat')
CountriesThatStartRegions = [1,4,6,24,42,49,55, -1];
RegionIndices = [1,9;10,15;16,69;70,123;124,144;145,162;163,180];
Countries = 60;
SeriesPerCountry = 3;
blocks = 36;
save('kowdataJan7')
clear

