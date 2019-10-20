% clear;clc;
% simpath = 'TimeBreakSimulations/';
% files = dir(join([simpath,'*.mat']));
% x =natsortfiles({files.name});
%
% c = str2double(cell2mat(regexp(x{1}, '[0-9]','match')));
% N = floor(length(x)/2);
% beg = 1:N;
% G = length(beg);
% for g = 1:N
%     set1 = x{G+ g};
%     datapath = join([simpath,set1]);
%     ml1 = load(datapath, 'ml');
%     set2 = x{g};
%     datapath = join([simpath,set2]);
%     ml2 = load(datapath, 'ml');
%     sumMls(g,2) = ml1.ml + ml2.ml;
%     sumMls(g,1) = c;
%     c = c + 1;
% end
% hold on
% plot(sumMls(:,1), sumMls(:,2))
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
% clear;clc;
% savepath = '~/GoogleDrive/statespace/';
% simpath = 'tbk_results/';
% files = dir(join([simpath,'*.mat']));
% x =natsortfiles({files.name});
% c = str2double(cell2mat(regexp(x{1}, '[0-9]','match')));
% N = floor(length(x)/2);
% beg = 1:N;
% c = str2double(cell2mat(regexp(x{1}, '[0-9]','match')));
% N = floor(length(x)/2);
% beg = 1:N;
% G = length(beg);
% 
% for g = 1:N
%     set1 = x{G+ g}
%     datapath = join([simpath,set1]);
%     ml1 = load(datapath, 'ml');
%     set2 = x{g}
%     datapath = join([simpath,set2]);
%     ml2 = load(datapath, 'ml');
%     sumMls(g,2) = ml1.ml + ml2.ml;
%     sumMls(g,1) = c;
%     c = c + 1
% end
% 
% [a, b] = max(sumMls(:,2))
% tbaxis = 1966:2011;
% mlfull = load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/BigKowResults/Old/Result_kowz.mat', 'ml');
% mlfull = mlfull.ml
% hold on 
% tbp = plot(tbaxis, ones(length(tbaxis),1).*mlfull);
% plot(tbaxis, sumMls(:,2))
% [a,b] = max(sumMls)
% saveas(tbp, join([savepath,'tbp.jpeg']))
% Max occurs at End 25 Beg 26
% load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/tbk_results/Result_TimeBreakKowEnd25.mat')
% csvwrite('vdend', varianceDecomp)
% load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/tbk_results/Result_TimeBreakKowBeg26.mat')
% csvwrite('vdbeg', varianceDecomp)
% plot(varianceDecomp(1:3:180,2), '.')
%%%%%%%%%%%%%%%%%%%%%%%%
%% Application KOW dataset
clear;clc;
savepath = '~/GoogleDrive/statespace/';

load('TestDir/Result_kowz_19_Oct_2019_21_15_51.mat')
sumFt = mean(storeFt,3);
sumBeta = mean(storeBeta, 2);
sumOM = mean(storeOM, 3);
sig = std(storeFt,[],3);
xaxis = 1962:2014;
sdband = 1.96.*sig;
upper = sumFt + sdband;
lower = sumFt - sdband;
LW = .75;
COLOR = [1,0,0];
facealpha = .3;
fillX = [xaxis, fliplr(xaxis)];
fillY = [upper, fliplr(lower)];

% load('BigKowResults/Result_kowz_03_Oct_2019_07_13_54.mat')
% load('BigKowResults/Result_kowzb_19_Oct_2019_11_52_53.mat')
% load('BigKowResults/Result_kowz__18_Oct_2019_16_31_05.mat')
% load('BigKowResults/Result_kow_stand.mat')
% load('BigKowResults/Old/Result_kowz.mat')
% xaxis = 1962:2014;
% variance = sumFt2 - sumFt.^2;
% sig = sqrt(variance);
% sdband = 1.9.*sig;
% upper = sumFt + sdband;
% lower = sumFt - sdband;
% LW = .75;
% COLOR = [1,0,0];
% facealpha = .3;
% fillX = [xaxis, fliplr(xaxis)];
% fillY = [upper, fliplr(lower)];

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

vd = zeros(K,3) ;
vareps = var(reshape(Xt*sumBeta,K,T), [],2);
facCount = 1;
for k = 1:3
    Info = InfoCell{1,k};
    Regions = size(Info,1);
    for r = 1:Regions
        subsetSelect = Info(r,1):Info(r,2);
        vd(subsetSelect,k) = var(sumOM(subsetSelect,k).*sumFt(facCount,:),[],2);
        facCount = facCount + 1;
    end
end
varianceDecomp = [vareps,vd];
varianceDecomp = varianceDecomp./sum(varianceDecomp,2);

mean(sumOM(:,1))
mean(varianceDecomp(:,2))

writeVdToFile('navd.txt', varianceDecomp, NA)
writeVdToFile('ocvd.txt', varianceDecomp, OCEAN)
writeVdToFile('lavd.txt', varianceDecomp, LA)
writeVdToFile('eurvd.txt', varianceDecomp, EUR)
writeVdToFile('afrvd.txt', varianceDecomp, AFRICA)
writeVdToFile('asiadevelopvd.txt', varianceDecomp, ASIADEVELOP)
writeVdToFile('asiavd.txt', varianceDecomp, ASIA)


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
% oceania  = plot(xaxis, sumFt(3,:), 'black')
%  saveas(oceania, join([savepath, 'oceania.jpeg']))

%% Latin America
% figure
% h = fill(fillX(1,:), fillY(4,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% latinAmerica  = plot(xaxis, sumFt(4,:), 'black')
%  saveas(latinAmerica, join([savepath, 'latinAmerica.jpeg']))

%% Africa
% figure
% hold on
% africa  = plot(xaxis, sumFt(6,:), 'black')
%  saveas(africa, join([savepath, 'africa.jpeg']))

%% Latin America and Africa
% figure
% hold on
% afrla = plot(xaxis, sumFt(4,:), 'black');
% plot(xaxis, sumFt(6,:), 'blue')
% saveas(afrla, join([savepath, 'afrla.jpeg']))

%% Europe
% figure
% europe = plot(xaxis, sumFt(5,:), 'black')
% shade([1974, 1980, 1992, 2008, 2011], [1975, 1982, 1993, 2009, 2013], 'black')
% saveas(europe, join([savepath, 'europefactor.jpeg']))
% hold off
% figure
% h = fill(fillX(1,:), fillY(5,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% europeregion  = plot(xaxis, sumFt(5,:), 'black')
% saveas(europeregion, join([savepath, 'europeregionplot.jpeg']))

%% Asia Developed
figure
asia  = plot(xaxis, sumFt(8,:), 'black')
saveas(asia, join([savepath, 'asia.jpeg']))
figure
h = fill(fillX(1,:), fillY(8,:), COLOR);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
hold on
asia_stderrs  = plot(xaxis, sumFt(8,:), 'black')
saveas(asia_stderrs, join([savepath, 'asia_stderrs.jpeg']))

%% Asia Developing
figure
h = fill(fillX(1,:), fillY(7,:), COLOR);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
hold on
asiadev_stderrs  = plot(xaxis, sumFt(7,:), 'black')
saveas(asiadev_stderrs, join([savepath, 'asiadev_stderrs.jpeg']))
figure
asiadevelop  = plot(xaxis, sumFt(7,:), 'black')
saveas(asiadevelop, join([savepath, 'asiadev.jpeg']))

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


