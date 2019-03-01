
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
corrUsaToNa =  corr([sumFt(2,:)', sumFt(9,:)'])
corrJapTo =  corr([sumFt(2,:)', sumFt(10,:)'])
corrMexToNa =  corr([sumFt(2,:)', sumFt(10,:)'])

% corrHKToAsD =  corr([sumFt(8,:)', sumFt(63,:)'])
% corrJapToAsD =  corr([sumFt(8,:)', sumFt(64,:)'])
% corrKorToAsD =  corr([sumFt(8,:)', sumFt(65,:)'])
% corrThaiToAsD =  corr([sumFt(8,:)', sumFt(68,:)'])
% plotSectorFactor(sumFt(1,:), sumFt2(1,:), 1964:2014, [pathtosave,'worldfactor.jpg'], 'World')
% plotSectorFactor(sumFt(2,:), sumFt2(2,:), 1964:2014, [pathtosave,'nafactor.jpg'], 'North America')
% plotSectorFactor(sumFt(9,:), sumFt2(9,:), 1964:2014, [pathtosave,'usafactor.jpg'], 'USA')
% plotSectorFactor(sumFt(10,:), sumFt2(10,:), 1964:2014, [pathtosave,'canadafactor.jpg'], 'Canada')
% plotSectorFactor(sumFt(11,:), sumFt2(11,:), 1964:2014, [pathtosave,'mexicofactor.jpg'], 'Mexico')
% plotSectorFactor(sumFt(5,:), sumFt2(5,:), 1964:2014, [pathtosave,'eurfactor.jpg'], 'Europe')
% plotSectorFactor(sumFt(32,:), sumFt2(32,:), 1964:2014, [pathtosave,'francefactor.jpg'], 'France')
% plotSectorFactor(sumFt(39,:), sumFt2(39,:), 1964:2014, [pathtosave,'icefactor.jpg'], 'Iceland')
% plotSectorFactor(sumFt(38,:), sumFt2(38,:), 1964:2014, [pathtosave,'greecefactor.jpg'], 'Greece')
% plotSectorFactor(sumFt(37,:), sumFt2(37,:), 1964:2014, [pathtosave,'germanyfactor.jpg'], 'Germany')
% plotSectorFactor(sumFt(40,:), sumFt2(40,:), 1964:2014, [pathtosave,'irelandfactor.jpg'], 'Ireland')
% plotSectorFactor(sumFt(49,:), sumFt2(49,:), 1964:2014, [pathtosave,'ukfactor.jpg'], 'United Kingdom')
% plotSectorFactor(sumFt(41,:), sumFt2(41,:), 1964:2014, [pathtosave,'italyfactor.jpg'], 'Italy')

% plotSectorFactor(sumFt(8,:), sumFt2(8,:), 1964:2014, [pathtosave,'asiadevelopedfactor.jpg'], 'Developed Asia')
% plotSectorFactor(sumFt(63,:), sumFt2(63,:), 1964:2014, [pathtosave,'hongkongfactor.jpg'], 'Hong Kong')
% plotSectorFactor(sumFt(64,:), sumFt2(64,:), 1964:2014, [pathtosave,'japanfactor.jpg'], 'Japan')
% plotSectorFactor(sumFt(65,:), sumFt2(65,:), 1964:2014, [pathtosave,'koreafactor.jpg'], 'Korea')
% plotSectorFactor(sumFt(68,:), sumFt2(68,:), 1964:2014, [pathtosave,'thaifactor.jpg'], 'Thailand')
% plotSectorFactor(sumFt(9,:), sumFt2(9,:), 1964:2014, [pathtosave,'usafactor.jpg'])