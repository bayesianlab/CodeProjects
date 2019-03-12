
%% FIRST PASS
% SPC
% clear;clc;
%  pathtosave = '~/GoogleDrive/statespace/';
% load('SPC_RepResults_13_Feb_2019_15_04_10.mat')
% plotFt(Factor, sumFt, sumFt2, InfoCell,  [pathtosave,'wrspcfirst.jpg'], [pathtosave,'cspcfirst.jpg'] )
% CR
% clear;clc;
%  pathtosave = '~/GoogleDrive/statespace/';
% load('SPC_RepResults_13_Feb_2019_15_21_39.mat')
% plotFt(Factor, sumFt, sumFt2, InfoCell,  [pathtosave,'wrcrfirst.jpg'], [pathtosave,'ccrfirst.jpg'] )


%% FULL
% SPC
% clear;clc;
% pathtosave = '~/GoogleDrive/statespace/';
% load('SPC_RepResults_15_Feb_2019_06_45_24.mat')
% plotFt(Factor, sumFt, sumFt2, InfoCell,  [pathtosave,'wrspc.jpg'], [pathtosave,'cspc.jpg'] )
% r2spc = figure;
% plotR2SPC(R2, [3,6,9,12]', Regions)
% saveas(r2spc, '~/GoogleDrive/statespace/R2SPC.jpg')

% CR

% clear;clc;
% pathtosave = '~/GoogleDrive/statespace/';
% load('SPC_RepResults_17_Feb_2019_13_44_29.mat')
% plotFt(Factor, sumFt, sumFt2, InfoCell,  [pathtosave,'wrcr.jpg'], [pathtosave,'ccr.jpg'] )
% r2cr = figure;
% plotR2(R2, CR)
% saveas(r2cr, '~/GoogleDrive/statespace/R2CR.jpg')
pathtosave = '~/GoogleDrive/statespace/';
load('worlddata_18_Feb_2019_18_29_30.mat')
corrUsaToNa =  corr([sumFt(2,:)', sumFt(9,:)']);
corrJapTo =  corr([sumFt(2,:)', sumFt(10,:)']);
corrMexToNa =  corr([sumFt(2,:)', sumFt(10,:)']);

% corrHKToAsD =  corr([sumFt(8,:)', sumFt(63,:)'])
% corrJapToAsD =  corr([sumFt(8,:)', sumFt(64,:)'])
% corrKorToAsD =  corr([sumFt(8,:)', sumFt(65,:)'])
% corrThaiToAsD =  corr([sumFt(8,:)', sumFt(68,:)'])
% xaxis = 1962:2014;
% plotSectorFactor(sumFt(1,:), sumFt2(1,:), xaxis, 'World',[pathtosave,'worldfactor.jpg'])
% plotSectorFactor(sumFt(2,:), sumFt2(2,:), xaxis, 'North America', [pathtosave,'nafactor.jpg'])
% plotSectorFactor(sumFt(9,:), sumFt2(9,:), xaxis, 'USA', [pathtosave,'usafactor.jpg'])
% plotSectorFactor(sumFt(10,:), sumFt2(10,:), xaxis, 'Canada', [pathtosave,'canadafactor.jpg'])
% plotSectorFactor(sumFt(11,:), sumFt2(11,:), xaxis, 'Mexico',, [pathtosave,'mexicofactor.jpg'])
% plotSectorFactor(sumFt(5,:), sumFt2(5,:), xaxis, 'Europe', [pathtosave,'eurfactor.jpg'])
% plotSectorFactor(sumFt(32,:), sumFt2(32,:), xaxis, 'France', [pathtosave,'francefactor.jpg'])
% plotSectorFactor(sumFt(39,:), sumFt2(39,:), xaxis, 'Iceland', [pathtosave,'icefactor.jpg'])
% plotSectorFactor(sumFt(38,:), sumFt2(38,:), xaxis, 'Greece', [pathtosave,'greecefactor.jpg'])
% plotSectorFactor(sumFt(37,:), sumFt2(37,:), xaxis, 'Germany', [pathtosave,'germanyfactor.jpg'])
% plotSectorFactor(sumFt(40,:), sumFt2(40,:), xaxis, 'Ireland', [pathtosave,'irelandfactor.jpg'])
% plotSectorFactor(sumFt(49,:), sumFt2(49,:), xaxis, 'United Kingdom', [pathtosave,'ukfactor.jpg'])
% plotSectorFactor(sumFt(41,:), sumFt2(41,:), xaxis,  'Italy',[pathtosave,'italyfactor.jpg'])

plotSectorFactor(sumFt(8,:), sumFt2(8,:), xaxis, 'Developed Asia', [pathtosave,'asiadevelopedfactor.jpg'])
plotSectorFactor(sumFt(63,:), sumFt2(63,:), xaxis, 'Hong Kong', [pathtosave,'hongkongfactor.jpg'])
plotSectorFactor(sumFt(64,:), sumFt2(64,:), xaxis, 'Japan', [pathtosave,'japanfactor.jpg'])
plotSectorFactor(sumFt(65,:), sumFt2(65,:), xaxis, 'Korea', [pathtosave,'koreafactor.jpg'])
plotSectorFactor(sumFt(68,:), sumFt2(68,:), xaxis, 'Thailand', [pathtosave,'thaifactor.jpg'])
