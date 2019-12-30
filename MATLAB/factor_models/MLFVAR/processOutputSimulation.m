clear;clc;
simpath = 'TbsSimDec19/';
files = dir(join([simpath,'*.mat']));
x =natsortfiles({files.name});
N = floor(length(x)/2);
beg = 1:N;
G = length(beg);
c=70;
for g = 1:N
    set1 = x{G+ g}
    datapath = join([simpath,set1]);
    ml1 = load(datapath, 'ml');
    set2 = x{g}
    datapath = join([simpath,set2]);
    ml2 = load(datapath, 'ml');
    sumMls(g,2) = ml1.ml + ml2.ml;
    sumMls(g,1) = c;
    c = c + 1;
end


[a,b]=max(sumMls);
tml = load('Result_totaltime_28_Dec_2019_19_50_09.mat', 'ml');
tml=tml.ml;
hold on
plot(sumMls(:,1),sumMls(:,2))
plot(sumMls(:,1),ones(size(sumMls,1),1).*tml)
tml
% clear;clc;
% load('Result_totaltime_28_Dec_2019_19_50_09.mat');
% mean(mean(storeVAR,3),2)
% mean(std(storeVAR,[],3),2)
% mean(storeOM,3)
% std(storeOM,[],3)
% mean(storeStateTransitions,3)
% std(storeStateTransitions,[],3)
% load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/TbsSimDec19/Result_TimeBreakEnd101_27_Dec_2019_01_40_36.mat')
% mean(mean(storeVAR,3),2)
% mean(std(storeVAR,[],3),2)
% mean(storeOM,3)
% std(storeOM,[],3)
% mean(storeStateTransitions,3)
% std(storeStateTransitions,[],3)
% load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/TbsSimDec19/Result_TimeBreakBeg102_27_Dec_2019_01_24_42.mat')
% mean(mean(storeVAR,3),2)
% mean(std(storeVAR,[],3),2)
% mean(storeOM,3)
% std(storeOM,[],3)
% mean(storeStateTransitions,3)
% std(storeStateTransitions,[],3)

% hold on
% [a,b]=max(sumMls(:,2))
% sumMls(19,:)
% plot(80:120, sumMls(:,2))
% plot(1:200, -1895.*ones(1,200), 'black')
% GreaterMls = sumMls(sumMls(:,2) > -1895, 1);

% clear;
% simpath = 'TimeBreakSimulations/';
% load(join([simpath, 'Result_totaltime.mat']))
% truefactor = DataCell{4};
% gamma = DataCell{6};
% G1 = DataCell{7};
% G2 = DataCell{8};
% residual = reshape(yt(:) - Xt*[.4;.4;.4], K, T);
% vector = [zeros(1,100), ones(1,100)];
% truefactor = vector.*truefactor;
% figure('Name', 'Using all timeperiods')
% hold on
% plot(truefactor, 'black')
% plot(sumFt(1,:), 'red')

% clear;
% simpath = 'TimeBreakSimulations/';
% load(join([simpath, 'Result_TimeBreakEnd100.mat']))
% truefactor = DataCell{4};
% gamma = DataCell{6};
% G1 = DataCell{7};
% G2 = DataCell{8};
% vector = [zeros(1,100), ones(1,100)];
% truefactor = vector.*truefactor;
% figure('Name', 'Split at t=100')
% hold on
% plot(truefactor, 'black')
% plot(sumFt(1,:), 'red')
% load(join([simpath, 'Result_TimeBreakBeg101.mat']))
% plot(101:200, sumFt(1,:), 'red')


% simpath = 'TimeBreakSimulations/';
% load(join([simpath, 'Result_totaltime.mat']))
% oneperiod = sumOM;
% oneperiodbeta = sumBeta;
% oneperiodst = sumST;
% load(join([simpath, 'Result_TimeBreakEnd100.mat']))
% firstperiod = sumOM;
% firstperiodbeta = sumBeta;
% firstperiodst = sumST;
% load(join([simpath, 'Result_TimeBreakBeg101.mat']))
% secondperiod= sumOM;
% secondperiodbeta = sumBeta;
% secondperiodst = sumST;
% trueG = DataCell{8};
% trueB = [.4;.4;4];
% trueST = 0.43;
% st = [oneperiodst, firstperiodst, secondperiodst, trueST];
% G = [oneperiod, firstperiod, secondperiod, trueG];
% Beta = [oneperiodbeta, firstperiodbeta, secondperiodbeta, trueB]
% matrix2latexmatrix(G, 'test.tex')
% matrix2latexmatrix(Beta, 'betamatrix.tex')
% matrix2latexmatrix(st,'st.tex')
% 
% 


%%%%%%%%%%%%%%%%%%%%%%%%
%% Application KOW dataset
% clear;clc;
% savepath = '~/GoogleDrive/statespace/';



% load('TestDir/Result_kowz_20_Oct_2019_14_13_03.mat')
% sumFt = mean(storeFt,3);
% sumBeta = mean(storeBeta, 2);
% sumOM = mean(storeOM, 3);
% sig = std(storeFt,[],3);
% xaxis = 1962:2014;
% sdband = 1.96.*sig;
% upper = sumFt + sdband;
% lower = sumFt - sdband;
% LW = .75;
% COLOR = [1,0,0];
% facealpha = .3;
% fillX = [xaxis, fliplr(xaxis)];
% fillY = [upper, fliplr(lower)];

% load('BigKowResults/Result_kowzb_19_Oct_2019_11_52_53.mat')
% load('BigKowResults/Result_kowz__18_Oct_2019_16_31_05.mat')
% load('BigKowResults/Result_kow_stand.mat')
% load('BigKowResults/Old/Result_kowz.mat')
% csvwrite('sumOM.csv', sumOM)
% 
% xaxis = 1962:2014;
% variance = sumFt2 - sumFt.^2;
% sig = sqrt(variance);
% sdband = 1.96.*sig;
% upper = sumFt + sdband;
% lower = sumFt - sdband;
% LW = .75;
% COLOR = [1,0,0];
% facealpha = .3;
% fillX = [xaxis, fliplr(xaxis)];
% fillY = [upper, fliplr(lower)];
% 
% NA = 1:9;
% NAOUT = 1:3:9;
% NACONS = 2:3:8;
% NAINV = 3:3:7;
% OCEAN = 10:15;
% OCEANOUT = 10:3:15;
% OCEANCONS = 11:3:14;
% OCEANINV = 12:3:13;
% LA = 16:69;
% LAOUT = 16:3:69;
% LACONS = 17:3:68;
% LAINV = 18:3:67;
% EUR = 70:123;
% EUROUT = 70:3:123;
% EURCONS = 71:3:122;
% EURINV = 72:3:121;
% AFRICA = 124:144;
% AFRICAOUT = 124:3:144;
% AFRICACONS = 125:3:143;
% AFRICAINV = 126:3:142;
% ASIADEVELOP = 145:162;
% ASIADEVELOPOUT = 145:3:162;
% ASIADEVELOPCONS = 146:3:161;
% ASIADEVELOPINV = 147:3:160;
% ASIA = 163:180;
% ASIAOUT = 163:3:180;
% ASIACONS = 164:3:179;
% ASIAINV = 165:3:178;



% writeVdToFile('navd.txt', varianceDecomp, NA)
% writeVdToFile('ocvd.txt', varianceDecomp, OCEAN)
% writeVdToFile('lavd.txt', varianceDecomp, LA)
% writeVdToFile('eurvd.txt', varianceDecomp, EUR)
% writeVdToFile('afrvd.txt', varianceDecomp, AFRICA)
% writeVdToFile('asiadevelopvd.txt', varianceDecomp, ASIADEVELOP)
% writeVdToFile('asiavd.txt', varianceDecomp, ASIA)


% Average var dec.
% disp('Regional')
% mean(varianceDecomp(NA,2))
% mean(varianceDecomp(OCEAN,2))
% mean(varianceDecomp(LA,2))
% mean(varianceDecomp(EUR,2))
% mean(varianceDecomp(AFRICA,2))
% mean(varianceDecomp(ASIADEVELOP,2))
% mean(varianceDecomp(ASIA,2))
% disp('Country')
% mean(varianceDecomp(OCEAN,3))
% mean(varianceDecomp(OCEAN,2))
% 
% disp('Specific Series')
% round([mean(varianceDecomp(NAOUT,2)),
% mean(varianceDecomp(NACONS,2)),
% mean(varianceDecomp(NAINV,2)),
% mean(varianceDecomp(OCEANOUT,2)),
% mean(varianceDecomp(OCEANCONS,2)),
% mean(varianceDecomp(OCEANINV,2)),
% mean(varianceDecomp(LAOUT,2)),
% mean(varianceDecomp(LACONS,2)),
% mean(varianceDecomp(LAINV,2))
% mean(varianceDecomp(EUROUT,2)),
% mean(varianceDecomp(EURCONS,2)),
% mean(varianceDecomp(EURINV,2)),
% mean(varianceDecomp(AFRICAOUT,2)),
% mean(varianceDecomp(AFRICACONS,2)),
% mean(varianceDecomp(AFRICAINV,2)),
% mean(varianceDecomp(ASIADEVELOPOUT,2)),
% mean(varianceDecomp(ASIADEVELOPCONS,2)),
% mean(varianceDecomp(ASIADEVELOPINV,2)),
% mean(varianceDecomp(ASIAOUT,2)),
% mean(varianceDecomp(ASIACONS,2)),
% mean(varianceDecomp(ASIAINV,2))], 3)
% 
% round([mean(varianceDecomp(NAOUT,3)),
% mean(varianceDecomp(NACONS,3)),
% mean(varianceDecomp(NAINV,3)),
% mean(varianceDecomp(OCEANOUT,3)),
% mean(varianceDecomp(OCEANCONS,3)),
% mean(varianceDecomp(OCEANINV,3)),
% mean(varianceDecomp(LAOUT,3)),
% mean(varianceDecomp(LACONS,3)),
% mean(varianceDecomp(LAINV,3)),
% mean(varianceDecomp(EUROUT,3)),
% mean(varianceDecomp(EURCONS,3)),
% mean(varianceDecomp(EURINV,3)),
% mean(varianceDecomp(AFRICAOUT,3)),
% mean(varianceDecomp(AFRICACONS,3)),
% mean(varianceDecomp(AFRICAINV,3)),
% mean(varianceDecomp(ASIADEVELOPOUT,3)),
% mean(varianceDecomp(ASIADEVELOPCONS,3)),
% mean(varianceDecomp(ASIADEVELOPINV,3)),
% mean(varianceDecomp(ASIAOUT,3)),
% mean(varianceDecomp(ASIACONS,3)),
% mean(varianceDecomp(ASIAINV,3))], 3)

%% World
% figure
% h = fill(fillX(1,:), fillY(1,:), COLOR);
% hold on 
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% world = plot(xaxis, sumFt(1,:), 'black');
% saveas(world, join([savepath, 'world_with_sd.jpeg']))
% 
% 
% 
%% North America
% figure
% na = plot(xaxis, sumFt(2,:), 'black');
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% saveas(na, join([savepath,'nafactorplot_recessions.jpeg']))
% figure
% hold on
% box on
% usaout = plot(xaxis,sumFt(2,:), 'red');
% plot(xaxis,yt(1,:), 'black')
% saveas(usaout, join([savepath,'usaoutVsRegion.jpeg']))
% figure
% hold on 
% box on
% usaconsump = plot(xaxis,sumFt(2,:), 'red');
% plot(xaxis,yt(2,:), 'black')
% saveas(usaconsump, join([savepath,'usaconsVsRegion.jpeg']))
% figure
% hold on 
% box on
% usainv = plot(xaxis, sumFt(2,:), 'red');
% plot(xaxis, yt(3,:),'black')
% saveas(usainv, join([savepath,'usainvVsRegion.jpeg']))
% figure
% hold on 
% box on
% usacountryout = plot(xaxis, sumFt(9,:), 'red');
% plot(xaxis, yt(1,:),'black')
% saveas(usacountryout, join([savepath,'usacountryout.jpeg']))
% figure
% hold on 
% box on
% usacountrycons = plot(xaxis, sumFt(9,:), 'red');
% plot(xaxis, yt(2,:),'black')
% saveas(usacountryout, join([savepath,'usacountrycons.jpeg']))
% figure
% hold on 
% box on
% usacountryinv = plot(xaxis, sumFt(9,:), 'red');
% plot(xaxis, yt(3,:),'black')
% saveas(usacountryinv, join([savepath,'usacountryinv.jpeg']))
% hold off
% figure
% h = fill(fillX(1,:), fillY(2,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% naregion  = plot(xaxis, sumFt(2,:), 'black')
% saveas(naregion, join([savepath, 'naregionplot.jpeg']))

%% Oceania
% figure
% h = fill(fillX(1,:), fillY(3,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% oceania  = plot(xaxis, sumFt(3,:), 'black');
%  saveas(oceania, join([savepath, 'oceania.jpeg']))

%% Latin America
% figure
% h = fill(fillX(1,:), fillY(4,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% latinAmerica  = plot(xaxis, sumFt(4,:), 'black');
% ylim([-2.25, 2.5])
%  saveas(latinAmerica, join([savepath, 'latinAmerica.jpeg']))

%% Africa
% figure
% h = fill(fillX(1,:), fillY(6,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% africa  = plot(xaxis, sumFt(6,:), 'black');
% ylim([-2.25, 2.5])
%  saveas(africa, join([savepath, 'africa.jpeg']))
 
% Latin America and Africa
% figure
% hold on
% afrla = plot(xaxis, sumFt(4,:), 'black');
% plot(xaxis, sumFt(6,:), 'blue')
% saveas(afrla, join([savepath, 'afrla.jpeg']))

%% Europe
% figure
% europe = plot(xaxis, sumFt(5,:), 'black');
% shade([1974, 1980, 1992, 2008, 2011], [1975, 1982, 1993, 2009, 2013], 'black')
% saveas(europe, join([savepath, 'europefactor.jpeg']))
% hold off
% figure
% h = fill(fillX(1,:), fillY(5,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% europeregion  = plot(xaxis, sumFt(5,:), 'black');
% ylim([-2.25, 2.5])
% saveas(europeregion, join([savepath, 'europeregionplot.jpeg']))
% 
% 
%% Asia Developed
% figure
% asia  = plot(xaxis, sumFt(8,:), 'black');
% saveas(asia, join([savepath, 'asia.jpeg']))
% figure
% h = fill(fillX(1,:), fillY(8,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% asia_stderrs  = plot(xaxis, sumFt(8,:), 'black');
% ylim([-2.25, 2.5])
% saveas(asia_stderrs, join([savepath, 'asia_stderrs.jpeg']))


%% Asia Developing
% figure
% h = fill(fillX(1,:), fillY(7,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% asiadev_stderrs  = plot(xaxis, sumFt(7,:), 'black');
% ylim([-2.25, 2.5])
% saveas(asiadev_stderrs, join([savepath, 'asiadev_stderrs.jpeg']))

% figure
% asiadevelop  = plot(xaxis, sumFt(7,:), 'black');
% saveas(asiadevelop, join([savepath, 'asiadev.jpeg']))

%% United States
% figure
% usa = plot(xaxis, sumFt(9,:), 'black')
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% hold off
% saveas(usa, 'usashaded.jpeg')
% figure
% h = fill(fillX(1,:), fillY(9,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% usa  = plot(xaxis, sumFt(9,:), 'black')
% saveas(usa, join([savepath,'usafactor.jpeg']))
% hold off
% 
% figure
% hold on
% usa= plot(xaxis, yt(1,:), 'black');
% plot(xaxis, sumOM(1,2)*sumFt(2,:), 'red')
% plot(xaxis, sumOM(1,3)*sumFt(9,:), 'blue')
% saveas(usa, join([savepath,'usaVsRegionCountry.jpeg']))

%% Canada and Mexico
% figure
% hold on
% canada= plot(xaxis, yt(4,:), 'black');
% plot(xaxis, sumOM(4,2)*sumFt(2,:), 'red')
% plot(xaxis, sumOM(4,3)*sumFt(10,:), 'blue')
% saveas(canada, join([savepath,'canadaVsRegionCountry.jpeg']))
% figure
% hold on 
% mexico= plot(xaxis, yt(7,:), 'black');
% plot(xaxis, sumOM(7,2)*sumFt(2,:), 'red')
% plot(xaxis, sumOM(7,3)*sumFt(11,:), 'blue')
% saveas(mexico, join([savepath,'mexicoVsRegionCountry.jpeg']))

% figure
% hold on
% canada= plot(xaxis, yt(4,:), 'black');
% plot(xaxis, sumOM(4,3)*sumFt(10,:), 'red')
% saveas(canada, join([savepath,'canadafactor.jpeg']))
%% N. Zealand
% figure
% nz = plot(xaxis, sumFt(13,:), 'black')
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% hold off
% figure
% h = fill(fillX(1,:), fillY(13,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% nz  = plot(xaxis, sumFt(13,:), 'black')
% saveas(nz, join([savepath,'nzfactor.jpeg']))
% hold off

%% Australia
% figure
% aus = plot(xaxis, sumFt(12,:), 'black')
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% hold off
% figure
% h = fill(fillX(1,:), fillY(12,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% aus  = plot(xaxis, sumFt(12,:), 'black')
% saveas(aus, join([savepath,'ausfactor.jpeg']))
% hold off

%% Germany
% figure
% hold on
% plot(xaxis, yhat(32,:))
% plot(xaxis, yt(32,:))
% germ = plot(xaxis, sumFt(5,:), 'black')
% h = fill(fillX(1,:), fillY(5,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% figure
% hold on
% germany  = plot(xaxis, sumFt(32,:), 'black')
% shade([1970, 1973, 1980, 1985, 1991, 2001, 2008, 2011], [1972, 1975, 1982, 1987, 1993,2005, 2009, 2013], 'black')

% figure
% hold on 
% h = fill(fillX(1,:), fillY(9,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% USA = plot(xaxis,sumFt(9,:), 'black')
% saveas(USA, join([savepath, 'USA.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(10,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CAN = plot(xaxis,sumFt(10,:), 'black')
% saveas(CAN, join([savepath, 'CAN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(11,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% MEX = plot(xaxis,sumFt(11,:), 'black')
% saveas(MEX, join([savepath, 'MEX.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(12,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% AUS = plot(xaxis,sumFt(12,:), 'black')
% saveas(AUS, join([savepath, 'AUS.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(13,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% NZL = plot(xaxis,sumFt(13,:), 'black')
% saveas(NZL, join([savepath, 'NZL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(14,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CRI = plot(xaxis,sumFt(14,:), 'black')
% saveas(CRI, join([savepath, 'CRI.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(15,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% DOM = plot(xaxis,sumFt(15,:), 'black')
% saveas(DOM, join([savepath, 'DOM.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(16,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% SLV = plot(xaxis,sumFt(16,:), 'black')
% saveas(SLV, join([savepath, 'SLV.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(17,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% GTM = plot(xaxis,sumFt(17,:), 'black')
% saveas(GTM, join([savepath, 'GTM.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(18,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% HND = plot(xaxis,sumFt(18,:), 'black')
% saveas(HND, join([savepath, 'HND.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(19,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% JAM = plot(xaxis,sumFt(19,:), 'black')
% saveas(JAM, join([savepath, 'JAM.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(20,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PAN = plot(xaxis,sumFt(20,:), 'black')
% saveas(PAN, join([savepath, 'PAN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(21,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% TTO = plot(xaxis,sumFt(21,:), 'black')
% saveas(TTO, join([savepath, 'TTO.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(22,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ARG = plot(xaxis,sumFt(22,:), 'black')
% saveas(ARG, join([savepath, 'ARG.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(23,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% BOL = plot(xaxis,sumFt(23,:), 'black')
% saveas(BOL, join([savepath, 'BOL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(24,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% BRA = plot(xaxis,sumFt(24,:), 'black')
% saveas(BRA, join([savepath, 'BRA.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(25,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CHL = plot(xaxis,sumFt(25,:), 'black')
% saveas(CHL, join([savepath, 'CHL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(26,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% COL = plot(xaxis,sumFt(26,:), 'black')
% saveas(COL, join([savepath, 'COL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(27,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ECU = plot(xaxis,sumFt(27,:), 'black')
% saveas(ECU, join([savepath, 'ECU.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(28,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PRY = plot(xaxis,sumFt(28,:), 'black')
% saveas(PRY, join([savepath, 'PRY.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(29,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PER = plot(xaxis,sumFt(29,:), 'black')
% saveas(PER, join([savepath, 'PER.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(30,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% URY = plot(xaxis,sumFt(30,:), 'black')
% saveas(URY, join([savepath, 'URY.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(31,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% VEN = plot(xaxis,sumFt(31,:), 'black')
% saveas(VEN, join([savepath, 'VEN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(32,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% FRA = plot(xaxis,sumFt(32,:), 'black')
% saveas(FRA, join([savepath, 'FRA.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(33,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% AUT = plot(xaxis,sumFt(33,:), 'black')
% saveas(AUT, join([savepath, 'AUT.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(34,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% BEL = plot(xaxis,sumFt(34,:), 'black')
% saveas(BEL, join([savepath, 'BEL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(35,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% DNK = plot(xaxis,sumFt(35,:), 'black')
% saveas(DNK, join([savepath, 'DNK.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(36,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% FIN = plot(xaxis,sumFt(36,:), 'black')
% saveas(FIN, join([savepath, 'FIN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(37,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% DEU = plot(xaxis,sumFt(37,:), 'black')
% saveas(DEU, join([savepath, 'DEU.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(38,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% GRC = plot(xaxis,sumFt(38,:), 'black')
% saveas(GRC, join([savepath, 'GRC.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(39,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ISL = plot(xaxis,sumFt(39,:), 'black')
% saveas(ISL, join([savepath, 'ISL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(40,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% IRL = plot(xaxis,sumFt(40,:), 'black')
% saveas(IRL, join([savepath, 'IRL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(41,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ITA = plot(xaxis,sumFt(41,:), 'black')
% saveas(ITA, join([savepath, 'ITA.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(42,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% LUX = plot(xaxis,sumFt(42,:), 'black')
% saveas(LUX, join([savepath, 'LUX.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(43,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% NLD = plot(xaxis,sumFt(43,:), 'black')
% saveas(NLD, join([savepath, 'NLD.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(44,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% NOR = plot(xaxis,sumFt(44,:), 'black')
% saveas(NOR, join([savepath, 'NOR.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(45,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PRT = plot(xaxis,sumFt(45,:), 'black')
% saveas(PRT, join([savepath, 'PRT.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(46,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ESP = plot(xaxis,sumFt(46,:), 'black')
% saveas(ESP, join([savepath, 'ESP.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(47,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% SWE = plot(xaxis,sumFt(47,:), 'black')
% saveas(SWE, join([savepath, 'SWE.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(48,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CHE = plot(xaxis,sumFt(48,:), 'black')
% saveas(CHE, join([savepath, 'CHE.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(49,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% GBR = plot(xaxis,sumFt(49,:), 'black')
% saveas(GBR, join([savepath, 'GBR.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(50,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CMR = plot(xaxis,sumFt(50,:), 'black')
% saveas(CMR, join([savepath, 'CMR.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(51,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CIV = plot(xaxis,sumFt(51,:), 'black')
% saveas(CIV, join([savepath, 'CIV.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(52,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% KEN = plot(xaxis,sumFt(52,:), 'black')
% saveas(KEN, join([savepath, 'KEN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(53,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% MAR = plot(xaxis,sumFt(53,:), 'black')
% saveas(MAR, join([savepath, 'MAR.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(54,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% SEN = plot(xaxis,sumFt(54,:), 'black')
% saveas(SEN, join([savepath, 'SEN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(55,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ZAF = plot(xaxis,sumFt(55,:), 'black')
% saveas(ZAF, join([savepath, 'ZAF.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(56,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ZWE = plot(xaxis,sumFt(56,:), 'black')
% saveas(ZWE, join([savepath, 'ZWE.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(57,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% BGD = plot(xaxis,sumFt(57,:), 'black')
% saveas(BGD, join([savepath, 'BGD.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(58,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% IND = plot(xaxis,sumFt(58,:), 'black')
% saveas(IND, join([savepath, 'IND.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(59,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% IDN = plot(xaxis,sumFt(59,:), 'black')
% saveas(IDN, join([savepath, 'IDN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(60,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PAK = plot(xaxis,sumFt(60,:), 'black')
% saveas(PAK, join([savepath, 'PAK.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(61,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PHL = plot(xaxis,sumFt(61,:), 'black')
% saveas(PHL, join([savepath, 'PHL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(62,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% LKA = plot(xaxis,sumFt(62,:), 'black')
% saveas(LKA, join([savepath, 'LKA.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(63,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% HKG = plot(xaxis,sumFt(63,:), 'black')
% saveas(HKG, join([savepath, 'HKG.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(64,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% JPN = plot(xaxis,sumFt(64,:), 'black')
% saveas(JPN, join([savepath, 'JPN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(65,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% KOR = plot(xaxis,sumFt(65,:), 'black')
% saveas(KOR, join([savepath, 'KOR.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(66,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% MYS = plot(xaxis,sumFt(66,:), 'black')
% saveas(MYS, join([savepath, 'MYS.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(67,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% SGP = plot(xaxis,sumFt(67,:), 'black')
% saveas(SGP, join([savepath, 'SGP.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(68,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% THA = plot(xaxis,sumFt(68,:), 'black')
% saveas(THA, join([savepath, 'THA.jpeg']))



