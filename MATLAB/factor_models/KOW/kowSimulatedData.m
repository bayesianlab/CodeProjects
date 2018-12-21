clear;clc;
% Dimension and setup
rng(1.6)
T = 500;
G = [-.5, -.3, .25];
gamma = .3;
SeriesPerCountry = 3;
beta = [.3, -.5, .25];
Regions = 2;
CountriesInRegion = 3;
Countries = Regions*CountriesInRegion;
mu = ones(Countries*SeriesPerCountry, 1).* -.5;
[yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
    kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, beta, G, gamma);
save('longt')
clear;
rng(1.6)
T = 100;
G = [-.5, -.3, .25];
gamma = .3;
SeriesPerCountry = 3;
beta = [.3, -.5, .25];
Regions = 2;
CountriesInRegion = 3;
Countries = Regions*CountriesInRegion;
mu = ones(Countries*SeriesPerCountry, 1).* -.5;
[yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
    kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, beta, G, gamma);
save('onehundredt')
clear;
rng(1.6)
T = 75;
G = [-.5, -.3, .25];
gamma = .3;
SeriesPerCountry = 3;
beta = [.3, -.5, .25];
Regions = 2;
CountriesInRegion = 3;
Countries = Regions*CountriesInRegion;
mu = ones(Countries*SeriesPerCountry, 1).* -.5;
[yt, Xt, Factor, RegionIndices,CountriesThatStartRegions ] = ...
    kowGenSimData(T, Regions, CountriesInRegion, SeriesPerCountry, mu, beta, G, gamma);
save('smallt')
clear;


