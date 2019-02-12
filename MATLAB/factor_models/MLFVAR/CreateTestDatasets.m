% clear;clc;
% rng(1101)
% SeriesPerCountry =5;
% CountriesInRegion = 3;
% Regions = 5;
% Countries = CountriesInRegion*Regions;
% T = 50;
% beta = ones(1,SeriesPerCountry+1).*.4;
% G = [.7, .5, .5]';
% % gamma = linspace(.1, .2, 1+Regions+Countries);
% gamma = ones(1, 1+Regions+Countries).*.5;
% K = SeriesPerCountry*CountriesInRegion*Regions;
% [DataCell] = ...
%     MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);
% 
% save('Sim5_3_5_50.mat', 'DataCell')
% 
% clear;clc;
% rng(1101)
% SeriesPerCountry =10;
% CountriesInRegion = 3;
% Regions = 5;
% Countries = CountriesInRegion*Regions;
% T = 50;
% beta = ones(1,SeriesPerCountry+1).*.4;
% G = [.7, .5, .5]';
% % gamma = linspace(.1, .2, 1+Regions+Countries);
% gamma = ones(1, 1+Regions+Countries).*.5;
% K = SeriesPerCountry*CountriesInRegion*Regions;
% [DataCell] = ...
%     MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);
% 
% save('Sim10_3_5_50.mat', 'DataCell')
% 
% clear;clc;
% rng(1101)
% SeriesPerCountry =20;
% CountriesInRegion = 3;
% Regions = 5;
% Countries = CountriesInRegion*Regions;
% T = 50;
% beta = ones(1,SeriesPerCountry+1).*.4;
% G = [.7, .5, .5]';
% % gamma = linspace(.1, .2, 1+Regions+Countries);
% gamma = ones(1, 1+Regions+Countries).*.5;
% K = SeriesPerCountry*CountriesInRegion*Regions;
% [DataCell] = ...
%     MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);
% save('Sim20_3_5_50.mat', 'DataCell')
% 
% clear;clc;
% rng(1101)
% SeriesPerCountry =5;
% CountriesInRegion = 5;
% Regions = 5;
% Countries = CountriesInRegion*Regions;
% T = 100;
% beta = ones(1,SeriesPerCountry+1).*.4;
% G = [.7, .5, .5]';
% % gamma = linspace(.1, .2, 1+Regions+Countries);
% gamma = ones(1, 1+Regions+Countries).*.5;
% K = SeriesPerCountry*CountriesInRegion*Regions;
% [DataCell] = ...
%     MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);
% 
% save('Sim5_5_5_100.mat', 'DataCell')
% 
% clear;clc;
% rng(1101)
% SeriesPerCountry =5;
% CountriesInRegion = 5;
% Regions = 5;
% Countries = CountriesInRegion*Regions;
% T = 50;
% beta = ones(1,SeriesPerCountry+1).*.4;
% G = [.7, .5, .5]';
% % gamma = linspace(.1, .2, 1+Regions+Countries);
% gamma = ones(1, 1+Regions+Countries).*.5;
% K = SeriesPerCountry*CountriesInRegion*Regions;
% [DataCell] = ...
%     MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);
% 
% save('Sim5_5_5_50.mat', 'DataCell')
% 
% clear;clc;
% rng(1101)
% SeriesPerCountry =10;
% CountriesInRegion = 10;
% Regions = 10;
% Countries = CountriesInRegion*Regions;
% T = 50;
% beta = ones(1,SeriesPerCountry+1).*.4;
% G = [.7, .5, .5]';
% % gamma = linspace(.1, .2, 1+Regions+Countries);
% gamma = ones(1, 1+Regions+Countries).*.5;
% K = SeriesPerCountry*CountriesInRegion*Regions;
% [DataCell] = ...
%     MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);
% 
% save('Sim10_10_10_50.mat', 'DataCell')
% 
% clear;clc;
% rng(1101)
% SeriesPerCountry =100;
% CountriesInRegion = 2;
% Regions = 2;
% Countries = CountriesInRegion*Regions;
% T = 50;
% beta = ones(1,SeriesPerCountry+1).*.4;
% G = [.7, .5, .5]';
% % gamma = linspace(.1, .2, 1+Regions+Countries);
% gamma = ones(1, 1+Regions+Countries).*.5;
% K = SeriesPerCountry*CountriesInRegion*Regions;
% [DataCell] = ...
%     MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);
% 
% save('Sim100_2_2_50.mat', 'DataCell')



clear;clc;
rng(1101)
SeriesPerCountry =5;
CountriesInRegion = 1;
Regions = 1;
Countries = CountriesInRegion*Regions;
T = 50;
beta = ones(1,SeriesPerCountry+1).*.4;
G = [.7, 0, .5]';
% gamma = linspace(.1, .2, 1+Regions+Countries);
gamma = ones(1, 1+Regions+Countries).*.5;
K = SeriesPerCountry*CountriesInRegion*Regions;
[DataCell] = ...
    MLFdata(T, Regions, CountriesInRegion,SeriesPerCountry,beta, G, gamma);

save('Experimental.mat', 'DataCell')
