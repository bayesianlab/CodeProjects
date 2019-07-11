clear;clc;
load('kow.mat')

yt = kowy(:, 47:end);
[K,T] = size(yt);
Xt = kowx((46*180)+1:end,:);
v0 = 5;
r0 = 10;
CountriesThatStartRegions = [1,4,6,24,42,49,55, -1];
RegionIndices = [1,9;10,15;16,69;70,123;124,144;145,162;163,180];
Countries=60;
Regions = 7;
SeriesPerCountry=3;
nFactors = Countries + Regions + 1;
initobsmod = ones(K,3).*[1,1,1];
initGamma = ones(nFactors,1).*.5;
initBeta = 1;
blocks = 20;
RegionBlocks = Countries;

save('kowperiod2.mat')