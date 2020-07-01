
clear;clc;
savepath = '~/GoogleDrive/statespace/';
load('ResultsUsedInPaper/Result_region_country_march18_21_Mar_2020_01_46_29.mat')
sortFt = sort(storeFt,3);

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


OUT = 1:3:180;
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

varianceDecomp

% writeVdToFile('navd_regioncountry.txt', varianceDecomp, NA)
% writeVdToFile('ocvd_regioncountry.txt', varianceDecomp, OCEAN)
% writeVdToFile('lavd_regioncountry.txt', varianceDecomp, LA)
% writeVdToFile('eurvd_regioncountry.txt', varianceDecomp, EUR)
% writeVdToFile('afrvd_regioncountry.txt', varianceDecomp, AFRICA)
% writeVdToFile('asiadevelopvd_regioncountry.txt', varianceDecomp, ASIADEVELOP)
% writeVdToFile('asiavd_regioncountry.txt', varianceDecomp, ASIA)

% Average var dec.
disp('Regional')
[mean(varianceDecomp(NAOUT,2))
mean(varianceDecomp(OCEANOUT,2)),
mean(varianceDecomp(LAOUT,2)),
mean(varianceDecomp(EUROUT,2)),
mean(varianceDecomp(AFRICAOUT,2)),
mean(varianceDecomp(ASIADEVELOPOUT,2)),
mean(varianceDecomp(ASIAOUT,2))]
disp('Country')
[mean(varianceDecomp(NAOUT,3)),
mean(varianceDecomp(OCEANOUT,3)),
mean(varianceDecomp(LAOUT,3)),
mean(varianceDecomp(EUROUT,3)),
mean(varianceDecomp(AFRICAOUT,3)),
mean(varianceDecomp(ASIADEVELOPOUT,3)),
mean(varianceDecomp(ASIAOUT,3))]

[mean(varianceDecomp(NACONS,3)),
mean(varianceDecomp(OCEANCONS,3)),
mean(varianceDecomp(LACONS,3)),
mean(varianceDecomp(EURCONS,3)),
mean(varianceDecomp(AFRICACONS,3)),
mean(varianceDecomp(ASIADEVELOPCONS,3)),
mean(varianceDecomp(ASIACONS,3))]

[mean(varianceDecomp(NA,3)),
mean(varianceDecomp(OCEAN,3)),
mean(varianceDecomp(LA,3)),
mean(varianceDecomp(EUR,3)),
mean(varianceDecomp(AFRICA,3)),
mean(varianceDecomp(ASIADEVELOP,3)),
mean(varianceDecomp(ASIA,3))]

mean(varianceDecomp(OUT,2))
mean(varianceDecomp(OUT,3))
mean(varianceDecomp(OUT,1))
%% North America
% figure
% hold on 
% h = fill(fillX(1,:), fillY(8,:), COLOR);
% USA=patch([xaxis, fliplr(xaxis)], [sortFt(8,:,200), fliplr(sortFt(8,:,7800)) ], 'red', 'FaceAlpha', facealpha )

% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% USA = plot(xaxis,Ft(8,:), 'black')
% saveas(USA, join([savepath, 'USA.jpeg']))
% figure
% h = fill(fillX(1,:), fillY(1,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% usaregion  = plot(xaxis, Ft(1,:), 'black');
% figure
% na = plot(xaxis, Ft(1,:), 'black');
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% saveas(na, join([savepath,'nafactorplot_recessions.jpeg']))

%% Europe
% figure
% europe = plot(xaxis, Ft(4,:), 'black');
% shade([1974, 1980, 1992, 2008, 2011], [1975, 1982, 1993, 2009, 2013], 'black')
% saveas(europe, join([savepath, 'europefactor_recessions.jpeg']))
% hold off
% figure
% h = fill(fillX(1,:), fillY(4,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% europeregion  = plot(xaxis, Ft(4,:), 'black');
% saveas(europeregion, join([savepath, 'europeregionplot.jpeg']))
% figure
% hold on 
% h = fill(fillX(1,:), fillY(36,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% DEU = plot(xaxis,Ft(36,:), 'black')
% saveas(DEU, join([savepath, 'DEU.jpeg']))



%% Latin America
% figure
% h = fill(fillX(1,:), fillY(3,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% latinAmerica  = plot(xaxis, Ft(3,:), 'black');
% shade([1980, 2007], [1983, 2009], 'black')
%  saveas(latinAmerica, join([savepath, 'latinAmerica.jpeg']))

%  figure 
%  hold on 
%  chile  = plot(xaxis, Ft(24,:), 'black');
%  plot(xaxis, yt(49,:))
%  plot(xaxis, yt(50,:))
%  plot(xaxis, yt(51,:))

% hold on 
% chile=patch([xaxis, fliplr(xaxis)], [sortFt(24,:,200), fliplr(sortFt(24,:,7800)) ], 'red', 'FaceAlpha', facealpha )
% plot(xaxis,sortFt(24,:,4000), '--')
%  saveas(chile, join([savepath, 'chile.jpeg']))

 % plot(xaxis,yt(49,:))
%% Oceania
% figure
% h = fill(fillX(1,:), fillY(2,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% oceania  = plot(xaxis, Ft(2,:), 'black');
%  saveas(oceania, join([savepath, 'oceania.jpeg']))

%% Africa
% figure
% h = fill(fillX(1,:), fillY(5,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% africa  = plot(xaxis, Ft(5,:), 'black');
%  saveas(africa, join([savepath, 'africa.jpeg']))
 
 %% Asia Developing
% figure
% h = fill(fillX(1,:), fillY(6,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% asiadev_stderrs  = plot(xaxis, Ft(6,:), 'black');
% saveas(asiadev_stderrs, join([savepath, 'asiadeveloping_stderrs.jpeg']))

% figure
% asiadevelop  = plot(xaxis, Ft(6,:), 'black');
% saveas(asiadevelop, join([savepath, 'asiadev.jpeg']))

%% Asia Developed
% figure
% asia  = plot(xaxis, Ft(7,:), 'black');
% saveas(asia, join([savepath, 'asia.jpeg']))
% figure
% h = fill(fillX(1,:), fillY(7,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% asia_stderrs  = plot(xaxis, Ft(7,:), 'black');
% saveas(asia_stderrs, join([savepath, 'asia_stderrs.jpeg']))

% Ftindxmat = CreateFactorIndexMat(InfoCell);
% muvar = mean(storeVAR,3)';
% must = mean(storeStateTransitions,3);
% muom = mean(storeOM,3);
% 

% must(Ftindxmat(1,:),:)
% yirf= HdfvarIRF(must(Ftindxmat(1,:),:), muvar(1,:), muom(1:3,:), 50, [1;0]);
% hold on
% plot(yirf(1,:))
% plot(yirf(2,:))
% plot(yirf(3,:))


% svar = sort(storeVAR, 3);
% lovar = svar(:,:,200)';
% hivar = svar(:,:,7800)';
% sst = sort(storeStateTransitions,3);
% lost = sst(:,:,200);
% hist = sst(:,:,7800);
% som = sort(storeOM,3);
% loom = som(:,:,200);
% hiom = som(:,:,7800);
% 
% yirf= HdfvarIRF(lost(Ftindxmat(1,:),:), lovar(1,:), loom(1:3,:), 50, [1;0]);
% loom(1:3,:)
% plot(yirf(1,:))


