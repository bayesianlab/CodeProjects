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


% clear;clc;
% simpath = 'TBKOW/';
% files = dir(join([simpath,'*.mat']));
% x =natsortfiles({files.name});
%
% c = str2double(cell2mat(regexp(x{1}, '[0-9]','match')));
% N = floor(length(x)/2);
% beg = 1:N;
%
% c = str2double(cell2mat(regexp(x{1}, '[0-9]','match')));
% N = floor(length(x)/2);
% beg = 1:N;
% G = length(beg);
%
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

%%%%%%%%%%%%%%%%%%%%%%%%
%% Application KOW dataset
clear;clc;
NA = 1:9;
OCEAN = 10:15;
LA = 16:69;
EUR = 70:123;
AFRICA = 124:144;
ASIADEVELOP = 145:162;
ASIA = 163:180;

savepath = '~/GoogleDrive/statespace/';
load('BigKowResults/Result_kowz.mat')


xaxis = 1962:2014;
variance = sumFt2 - sumFt.^2;
sig = sqrt(variance);
upper = sumFt + 1.5.*sig;
lower = sumFt - 1.5.*sig;
LW = .75;
COLOR = [1,0,0];
facealpha = .3;
fillX = [xaxis, fliplr(xaxis)];
fillY = [upper, fliplr(lower)];

Idens = MakeObsModelIdentity(InfoCell);
Gt = makeStateObsModel(sumOM, Idens, 0);
mut = reshape(Xt*sumBeta, K,T);
mut2 = Gt*sumFt;
yhat = mut+ mut2;
ytdemut= yt-mut;
errs = ytdemut - mut2;
factorVariances = zeros(K,levels);
facCount = 1;
for k = 1:levels
    Info = InfoCell{1,k};
    Regions = size(Info,1);
    ConditionalOM = makeStateObsModel(sumOM, Identities, k);
    
    for r = 1:Regions
        subsetSelect = Info(r,1):Info(r,2);
        regionmu = mut(subsetSelect,:);
        factorVariances(subsetSelect,k) = var(sumOM(subsetSelect,k).*sumFt(facCount,:),[],2);
        facCount = facCount + 1;
    end
end

E = var(errs,[],2);

varDec = factorVariances./sum([factorVariances, E],2);
[a,b] = max(varDec);

% Average var dec.
mean(varDec(NA,2))
mean(varDec(OCEAN,2))
mean(varDec(LA,2))
mean(varDec(EUR,2))
mean(varDec(AFRICA,2))
mean(varDec(ASIADEVELOP,2))
mean(varDec(ASIA,2))

ml
%% World
% h = fill(fillX(1,:), fillY(fs,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% world = plot(xaxis, sumFt(1,:), 'black');
% saveas(world, join([savepath,'worldfactor.jpeg']))
% saveas(world, join([savepath, 'world.jpeg']))

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

%% North America
% figure
% na = plot(xaxis, sumFt(2,:), 'blue');
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
% h = fill(fillX(1,:), fillY(5,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% naregion  = plot(xaxis, sumFt(5,:), 'black')
% saveas(naregion, join([savepath, 'naregionplot.jpeg']))


%% Oceania
% hold off
% figure
% ocean = plot(xaxis, sumFt(3,:), 'black')
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% 
% figure
% h = fill(fillX(1,:), fillY(3,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% ocean  = plot(xaxis, sumFt(3,:), 'black')
% saveas(ocean, join([savepath,'oceanfactor.jpeg']))
% hold off
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

%% Asia Developed
% figure
% h = fill(fillX(1,:), fillY(8,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% asia  = plot(xaxis, sumFt(8,:), 'black')
% saveas(asia, join([savepath, 'asia.jpeg']))
% ag = yt(ASIA,:);
% asgdp = ag(1:3:size(ag,1),:);
% plot(xaxis,asgdp(1,:))
%% Asia Developing
% figure
% h = fill(fillX(1,:), fillY(7,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% asiadev  = plot(xaxis, sumFt(7,:), 'black')
% agdp = yt(ASIADEVELOP,:);
% agdp = agdp(1:3:size(agdp,1),:);
% 1:3:size(agdp,1)
% plot(xaxis, agdp(5,:))

% saveas(asiadev, join([savepath, 'asiadev.jpeg']))

%% Latin America
% figure
% h = fill(fillX(1,:), fillY(4,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% latinAmerica  = plot(xaxis, sumFt(4,:), 'black')
%  saveas(latinAmerica, join([savepath, 'latinAmerica.jpeg']))

%% Africa
% figure
% h = fill(fillX(1,:), fillY(6,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% africa  = plot(xaxis, sumFt(6,:), 'black')
%  saveas(africa, join([savepath, 'africa.jpeg']))

%% Latin America and Africa
% figure
% hold on
% afrla = plot(xaxis, sumFt(4,:), 'black');
% plot(xaxis, sumFt(6,:), 'blue')
% saveas(afrla, join([savepath, 'afrla.jpeg']))

%% Oceania
% figure
% h = fill(fillX(1,:), fillY(3,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% oceania  = plot(xaxis, sumFt(3,:), 'black')
%  saveas(oceania, join([savepath, 'oceania.jpeg']))
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
% saveas(mexico, join([savepath,'mexicofactor.jpeg']))
% figure
% hold on
% canada= plot(xaxis, yt(4,:), 'black');
% plot(xaxis, sumOM(4,3)*sumFt(10,:), 'red')
% saveas(canada, join([savepath,'canadafactor.jpeg']))

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


