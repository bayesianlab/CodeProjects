



%% Application KOW dataset
clear;clc;
savepath = '~/GoogleDrive/statespace/';
load('ResultsUsedInPaper/NewMethod_Feb4th.mat')
% hold on
% plot(yt(1,:))
% plot(Ft(1,:))
% plot(Ft(2,:))
% plot(Ft(9,:))
% plot(yhat(1,:))


sig = std(storeFt,[],3);
xaxis = 1962:2014;
sdband = 2.*sig;
upper = Ft + sdband;
lower = Ft - sdband;
LW = .75;
COLOR = [1,0,0];
facealpha = .3;
fillX = [xaxis, fliplr(xaxis)];
fillY = [upper, fliplr(lower)];


NA = 1:9;
NAOUT = 1:3:9;
NACONS = 2:3:8;
NAINV = 3:3:7;
OCEAN = 10:15;
OCEANOUT = 10:3:15;
OCEANCONS = 11:3:14;
OCEANINV = 12:3:13;
LA = 16:69;
LAOUT = 16:3:69;
LACONS = 17:3:68;
LAINV = 18:3:67;
EUR = 70:123;
EUROUT = 70:3:123;
EURCONS = 71:3:122;
EURINV = 72:3:121;
AFRICA = 124:144;
AFRICAOUT = 124:3:144;
AFRICACONS = 125:3:143;
AFRICAINV = 126:3:142;
ASIADEVELOP = 145:162;
ASIADEVELOPOUT = 145:3:162;
ASIADEVELOPCONS = 146:3:161;
ASIADEVELOPINV = 147:3:160;
ASIA = 163:180;
ASIAOUT = 163:3:180;
ASIACONS = 164:3:179;
ASIAINV = 165:3:178;


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
% world = plot(xaxis, Ft(1,:), 'black');
% saveas(world, join([savepath, 'world_with_sd.jpeg']))

%% North America
% figure
% na = plot(xaxis, Ft(2,:), 'black');
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% ylim([-.6, .45])
% saveas(na, join([savepath,'nafactorplot_recessions.jpeg']))

% figure
% hold on
% box on
% plot(xaxis,yt(1,:), 'black')
% plot(xaxis, Ft(1,:), 'LineStyle', ':', 'Color','black')
% plot(xaxis, Ft(2,:), 'LineStyle', '--', 'Color', 'blue')
% plot(xaxis, Ft(9,:), 'LineStyle', '-.',  'Color', 'red')
% saveas(gcf, join([savepath,'usaVsAllFactors.jpeg']))
% figure
% hold on 
% box on
% usaconsump = plot(xaxis,Ft(2,:), 'red');
% plot(xaxis,yt(2,:), 'black')
% saveas(usaconsump, join([savepath,'usaconsVsRegion.jpeg']))
% usainv=figure;
% hold on 
% box on
% plot(xaxis, Ft(2,:), 'red');
% plot(xaxis, yt(3,:)- Xbeta(3,:),'black')
% saveas(usainv, join([savepath,'usainvVsRegion.jpeg']))
% figure
% hold on 
% box on
% usacountryout = plot(xaxis, Ft(9,:), 'red');
% plot(xaxis, yt(1,:),'black')
% saveas(usacountryout, join([savepath,'usacountryout.jpeg']))
% figure
% hold on 
% box on
% usacountrycons = plot(xaxis, Ft(9,:), 'red');
% plot(xaxis, yt(2,:),'black')
% saveas(usacountryout, join([savepath,'usacountrycons.jpeg']))
% figure
% hold on 
% box on
% usacountryinv = plot(xaxis, Ft(9,:), 'red');
% plot(xaxis, yt(3,:),'black')
% saveas(usacountryinv, join([savepath,'usacountryinv.jpeg']))
% hold off
% figure
% h = fill(fillX(1,:), fillY(2,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% naregion  = plot(xaxis, Ft(2,:), 'black')
% saveas(naregion, join([savepath, 'naregionplot.jpeg']))

%% Oceania
% figure
% h = fill(fillX(1,:), fillY(3,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% oceania  = plot(xaxis, Ft(3,:), 'black');
%  saveas(oceania, join([savepath, 'oceania.jpeg']))

%% Latin America
% figure
% h = fill(fillX(1,:), fillY(4,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% latinAmerica  = plot(xaxis, Ft(4,:), 'black');
% ylim([-2.25, 2.5])
%  saveas(latinAmerica, join([savepath, 'latinAmerica.jpeg']))

%% Africa
figure
h = fill(fillX(1,:), fillY(6,:), COLOR);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
hold on
africa  = plot(xaxis, Ft(6,:), 'black');
 saveas(africa, join([savepath, 'africa.jpeg']))
 
% Latin America and Africa
% figure
% hold on
% afrla = plot(xaxis, Ft(4,:), 'black');
% plot(xaxis, Ft(6,:), 'blue')
% saveas(afrla, join([savepath, 'afrla.jpeg']))

%% Europe
% figure
% europe = plot(xaxis, Ft(5,:), 'black');
% shade([1974, 1980, 1992, 2008, 2011], [1975, 1982, 1993, 2009, 2013], 'black')
% saveas(europe, join([savepath, 'europefactor.jpeg']))
% hold off
% figure
% h = fill(fillX(1,:), fillY(5,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% europeregion  = plot(xaxis, Ft(5,:), 'black');
% ylim([-.6, .6])
% saveas(europeregion, join([savepath, 'europeregionplot.jpeg']))
% 
% 
%% Asia Developed
% figure
% asia  = plot(xaxis, Ft(8,:), 'black');
% saveas(asia, join([savepath, 'asia.jpeg']))
% figure
% h = fill(fillX(1,:), fillY(8,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% asia_stderrs  = plot(xaxis, Ft(8,:), 'black');
% ylim([-2.25, 2.5])
% saveas(asia_stderrs, join([savepath, 'asia_stderrs.jpeg']))


%% Asia Developing
% figure
% h = fill(fillX(1,:), fillY(7,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% asiadev_stderrs  = plot(xaxis, Ft(7,:), 'black');
% ylim([-2.25, 2.5])
% saveas(asiadev_stderrs, join([savepath, 'asiadev_stderrs.jpeg']))

% figure
% asiadevelop  = plot(xaxis, Ft(7,:), 'black');
% saveas(asiadevelop, join([savepath, 'asiadev.jpeg']))

%% United States
% figure
% usa = plot(xaxis, Ft(9,:), 'black')
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% hold off
% saveas(usa, 'usashaded.jpeg')
% figure
% h = fill(fillX(1,:), fillY(9,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% usa  = plot(xaxis, Ft(9,:), 'black')
% saveas(usa, join([savepath,'usafactor.jpeg']))
% hold off
% 
% figure
% hold on
% usa= plot(xaxis, yt(1,:), 'black');
% plot(xaxis, sumOM(1,2)*Ft(2,:), 'red')
% plot(xaxis, sumOM(1,3)*Ft(9,:), 'blue')
% saveas(usa, join([savepath,'usaVsRegionCountry.jpeg']))

%% Canada and Mexico
% figure
% hold on
% canada= plot(xaxis, yt(4,:), 'black');
% plot(xaxis, sumOM(4,2)*Ft(2,:), 'red')
% plot(xaxis, sumOM(4,3)*Ft(10,:), 'blue')
% saveas(canada, join([savepath,'canadaVsRegionCountry.jpeg']))
% figure
% hold on 
% mexico= plot(xaxis, yt(7,:), 'black');
% plot(xaxis, sumOM(7,2)*Ft(2,:), 'red')
% plot(xaxis, sumOM(7,3)*Ft(11,:), 'blue')
% saveas(mexico, join([savepath,'mexicoVsRegionCountry.jpeg']))

% figure
% hold on
% canada= plot(xaxis, yt(4,:), 'black');
% plot(xaxis, sumOM(4,3)*Ft(10,:), 'red')
% saveas(canada, join([savepath,'canadafactor.jpeg']))
%% N. Zealand
% figure
% nz = plot(xaxis, Ft(13,:), 'black')
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% hold off
% figure
% h = fill(fillX(1,:), fillY(13,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% nz  = plot(xaxis, Ft(13,:), 'black')
% saveas(nz, join([savepath,'nzfactor.jpeg']))
% hold off

%% Australia
% figure
% aus = plot(xaxis, Ft(12,:), 'black')
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% hold off
% figure
% h = fill(fillX(1,:), fillY(12,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% aus  = plot(xaxis, Ft(12,:), 'black')
% saveas(aus, join([savepath,'ausfactor.jpeg']))
% hold off

%% Germany
% figure
% hold on
% plot(xaxis, yhat(32,:))
% plot(xaxis, yt(32,:))
% germ = plot(xaxis, Ft(5,:), 'black')
% h = fill(fillX(1,:), fillY(5,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% figure
% hold on
% germany  = plot(xaxis, Ft(32,:), 'black')
% shade([1970, 1973, 1980, 1985, 1991, 2001, 2008, 2011], [1972, 1975, 1982, 1987, 1993,2005, 2009, 2013], 'black')

% figure
% hold on 
% h = fill(fillX(1,:), fillY(9,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% USA = plot(xaxis,Ft(9,:), 'black')
% saveas(USA, join([savepath, 'USA.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(10,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CAN = plot(xaxis,Ft(10,:), 'black')
% saveas(CAN, join([savepath, 'CAN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(11,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% MEX = plot(xaxis,Ft(11,:), 'black')
% saveas(MEX, join([savepath, 'MEX.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(12,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% AUS = plot(xaxis,Ft(12,:), 'black')
% saveas(AUS, join([savepath, 'AUS.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(13,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% NZL = plot(xaxis,Ft(13,:), 'black')
% saveas(NZL, join([savepath, 'NZL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(14,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CRI = plot(xaxis,Ft(14,:), 'black')
% saveas(CRI, join([savepath, 'CRI.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(15,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% DOM = plot(xaxis,Ft(15,:), 'black')
% saveas(DOM, join([savepath, 'DOM.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(16,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% SLV = plot(xaxis,Ft(16,:), 'black')
% saveas(SLV, join([savepath, 'SLV.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(17,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% GTM = plot(xaxis,Ft(17,:), 'black')
% saveas(GTM, join([savepath, 'GTM.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(18,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% HND = plot(xaxis,Ft(18,:), 'black')
% saveas(HND, join([savepath, 'HND.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(19,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% JAM = plot(xaxis,Ft(19,:), 'black')
% saveas(JAM, join([savepath, 'JAM.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(20,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PAN = plot(xaxis,Ft(20,:), 'black')
% saveas(PAN, join([savepath, 'PAN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(21,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% TTO = plot(xaxis,Ft(21,:), 'black')
% saveas(TTO, join([savepath, 'TTO.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(22,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ARG = plot(xaxis,Ft(22,:), 'black')
% saveas(ARG, join([savepath, 'ARG.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(23,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% BOL = plot(xaxis,Ft(23,:), 'black')
% saveas(BOL, join([savepath, 'BOL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(24,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% BRA = plot(xaxis,Ft(24,:), 'black')
% saveas(BRA, join([savepath, 'BRA.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(25,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CHL = plot(xaxis,Ft(25,:), 'black')
% saveas(CHL, join([savepath, 'CHL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(26,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% COL = plot(xaxis,Ft(26,:), 'black')
% saveas(COL, join([savepath, 'COL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(27,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ECU = plot(xaxis,Ft(27,:), 'black')
% saveas(ECU, join([savepath, 'ECU.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(28,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PRY = plot(xaxis,Ft(28,:), 'black')
% saveas(PRY, join([savepath, 'PRY.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(29,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PER = plot(xaxis,Ft(29,:), 'black')
% saveas(PER, join([savepath, 'PER.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(30,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% URY = plot(xaxis,Ft(30,:), 'black')
% saveas(URY, join([savepath, 'URY.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(31,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% VEN = plot(xaxis,Ft(31,:), 'black')
% saveas(VEN, join([savepath, 'VEN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(32,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% FRA = plot(xaxis,Ft(32,:), 'black')
% saveas(FRA, join([savepath, 'FRA.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(33,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% AUT = plot(xaxis,Ft(33,:), 'black')
% saveas(AUT, join([savepath, 'AUT.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(34,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% BEL = plot(xaxis,Ft(34,:), 'black')
% saveas(BEL, join([savepath, 'BEL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(35,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% DNK = plot(xaxis,Ft(35,:), 'black')
% saveas(DNK, join([savepath, 'DNK.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(36,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% FIN = plot(xaxis,Ft(36,:), 'black')
% saveas(FIN, join([savepath, 'FIN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(37,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% DEU = plot(xaxis,Ft(37,:), 'black')
% saveas(DEU, join([savepath, 'DEU.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(38,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% GRC = plot(xaxis,Ft(38,:), 'black')
% saveas(GRC, join([savepath, 'GRC.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(39,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ISL = plot(xaxis,Ft(39,:), 'black')
% saveas(ISL, join([savepath, 'ISL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(40,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% IRL = plot(xaxis,Ft(40,:), 'black')
% saveas(IRL, join([savepath, 'IRL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(41,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ITA = plot(xaxis,Ft(41,:), 'black')
% saveas(ITA, join([savepath, 'ITA.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(42,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% LUX = plot(xaxis,Ft(42,:), 'black')
% saveas(LUX, join([savepath, 'LUX.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(43,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% NLD = plot(xaxis,Ft(43,:), 'black')
% saveas(NLD, join([savepath, 'NLD.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(44,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% NOR = plot(xaxis,Ft(44,:), 'black')
% saveas(NOR, join([savepath, 'NOR.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(45,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PRT = plot(xaxis,Ft(45,:), 'black')
% saveas(PRT, join([savepath, 'PRT.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(46,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ESP = plot(xaxis,Ft(46,:), 'black')
% saveas(ESP, join([savepath, 'ESP.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(47,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% SWE = plot(xaxis,Ft(47,:), 'black')
% saveas(SWE, join([savepath, 'SWE.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(48,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CHE = plot(xaxis,Ft(48,:), 'black')
% saveas(CHE, join([savepath, 'CHE.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(49,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% GBR = plot(xaxis,Ft(49,:), 'black')
% saveas(GBR, join([savepath, 'GBR.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(50,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CMR = plot(xaxis,Ft(50,:), 'black')
% saveas(CMR, join([savepath, 'CMR.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(51,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% CIV = plot(xaxis,Ft(51,:), 'black')
% saveas(CIV, join([savepath, 'CIV.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(52,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% KEN = plot(xaxis,Ft(52,:), 'black')
% saveas(KEN, join([savepath, 'KEN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(53,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% MAR = plot(xaxis,Ft(53,:), 'black')
% saveas(MAR, join([savepath, 'MAR.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(54,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% SEN = plot(xaxis,Ft(54,:), 'black')
% saveas(SEN, join([savepath, 'SEN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(55,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ZAF = plot(xaxis,Ft(55,:), 'black')
% saveas(ZAF, join([savepath, 'ZAF.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(56,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% ZWE = plot(xaxis,Ft(56,:), 'black')
% saveas(ZWE, join([savepath, 'ZWE.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(57,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% BGD = plot(xaxis,Ft(57,:), 'black')
% saveas(BGD, join([savepath, 'BGD.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(58,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% IND = plot(xaxis,Ft(58,:), 'black')
% saveas(IND, join([savepath, 'IND.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(59,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% IDN = plot(xaxis,Ft(59,:), 'black')
% saveas(IDN, join([savepath, 'IDN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(60,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PAK = plot(xaxis,Ft(60,:), 'black')
% saveas(PAK, join([savepath, 'PAK.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(61,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% PHL = plot(xaxis,Ft(61,:), 'black')
% saveas(PHL, join([savepath, 'PHL.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(62,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% LKA = plot(xaxis,Ft(62,:), 'black')
% saveas(LKA, join([savepath, 'LKA.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(63,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% HKG = plot(xaxis,Ft(63,:), 'black')
% saveas(HKG, join([savepath, 'HKG.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(64,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% JPN = plot(xaxis,Ft(64,:), 'black')
% saveas(JPN, join([savepath, 'JPN.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(65,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% KOR = plot(xaxis,Ft(65,:), 'black')
% saveas(KOR, join([savepath, 'KOR.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(66,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% MYS = plot(xaxis,Ft(66,:), 'black')
% saveas(MYS, join([savepath, 'MYS.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(67,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% SGP = plot(xaxis,Ft(67,:), 'black')
% saveas(SGP, join([savepath, 'SGP.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(68,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% THA = plot(xaxis,Ft(68,:), 'black')
% saveas(THA, join([savepath, 'THA.jpeg']))



