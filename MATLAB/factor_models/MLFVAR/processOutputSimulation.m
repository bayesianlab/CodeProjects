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

clear;clc;
NA = 1:9;
OCEAN = 10:15;
LA = 16:69;
EUR = 70:123;
AFRICA = 124:144;
ASIADEVLOP = 145:162;
ASIA = 163:180;

% savepath = '~/GoogleDrive/statespace/'
load('experimental.mat')

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
Gt = makeStateObsModel(sumOtherOM, Idens, 0);
mut = reshape(Xt*sumBeta, K,T);
mut2 = Gt*sumFt;
yhat = mut+ mut2;
vyt = var(yt,[],2);
factorVariances = zeros(K,levels);
facCount = 1;
for k = 1:levels
    Info = InfoCell{1,k};
    Regions = size(Info,1);
    ConditionalOM = makeStateObsModel(sumOM, Identities, k);
    
    mut = reshape(Xt*sumBeta,K,T);
    vydemut = var(yt-mut,[],2);
    for r = 1:Regions
        subsetSelect = Info(r,1):Info(r,2);
        regionmu = mut(subsetSelect,:);
        factorVariances(subsetSelect,k) = var(sumOtherOM(subsetSelect,k).*sumFt(facCount,:),[],2);
        facCount = facCount + 1;
    end
end

find (sum(factorVariances,2) > 1 )

CMR = [mut(124,:)', sumFt(1,:)', sumFt(6,:)', sumFt(50,:)'];

q = orthog(CMR);




% yy = var(yt,[],2);
% varianceDecomp
% sumOtherOM(1,:)


A = sumOtherOM(124,1).*sumFt(1,:)
B = sumOtherOM(124,2).*sumFt(6,:)
C = sumOtherOM(124,3).*sumFt(50,:)

ydemu = yt(124,:)-mut(124,:);
E = ydemu-(A+B+C);

vtot = var(A) + var(B) + var(C) + var(E)
var(A)/vtot
var(B)/vtot
var(C)/vtot
var(E)/vtot

% errs = sum( (yt(70,:)).^2,2)
% 
% onlyregion = sum((sumOM(70,1).*sumFt(1,:)).^2,2)
% 
% onlyregion/errs

% 

hold on 
plot(yt(124,:),'black')
plot(sumOM(124,3).*sumFt(50,:))



% plot(sumOM(70,2)*sumFt(5,:))
% plot(sumOM(1,3)*sumFt(9,:))
% plot(sumOM(70,1)*sumFt(1,:))
% sum([varianceDecomp] ,2)

% Average vd for country factors
% 70-123 Europe
% mean(sumVarianceDecomp(70:123,3))
% average vd for region in developing asia
% 145-162 Developing Asia
% mean(sumVarianceDecomp(145:162,2))
% mean([sumVarianceDecomp(145:147,2); sumVarianceDecomp(151:162,2)])
% india = yt(148:150,:);
% india_nomean = india - mean(india,2)
% indiaz = india_nomean./std(india,[],2)
% figure
% hold on
% h = fill(fillX(1,:), fillY(58,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% indiafigcons = plot(xaxis, indiaz(2,:), 'black')
% indiafigcons= plot(xaxis, sumFt(58,:), 'red')
% saveas(indiafigcons, join([savepath,'indiafigcons.jpeg']))
% figure
% hold on
% indiafigout = plot(xaxis, indiaz(1,:), 'black')
% indiafigout= plot(xaxis, sumFt(58,:), 'red')
% saveas(indiafigout, join([savepath,'indiafigout.jpeg']))
% corr([indiaz', sumFt(58,:)'])

% Pakistan
% pak = yt(154:156,:);
% pak_nomean = pak - mean(pak,2)
% pakz = pak_nomean./std(pak,[],2)
% figure
% hold on
% h = fill(fillX(1,:), fillY(60,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% pakfigout = plot(xaxis, pakz(1,:), 'black')
% pakfigout= plot(xaxis, sumFt(60,:), 'red')
% saveas(pakfigout, join([savepath,'pakfigout.jpeg']))
% figure
% hold on
% pakfigcons = plot(xaxis, pakz(2,:), 'black')
% pakfigcons= plot(xaxis, sumFt(60,:), 'red')
% saveas(pakfigcons, join([savepath,'pakfigcons.jpeg']))
% phl = yt(157:159,:);
% indo = yt(151:153,:);
% lka = yt(160:162,:);
% corr([india', pak', phl',  indo', lka', sumFt(58,:)'])

% 163-180 Developed Asia

% worldvd = round([sdvdlow(:,1), sumVarianceDecomp(:,1), sdvdup(:,1)], 4)
% matrix2latexmatrix( worldvd, join( [savepath, 'worldvd.tex'] ) )
%
% regionvd = round([sdvdlow(:,2) ,sumVarianceDecomp(:,2), sdvdup(:,2)], 4)
% matrix2latexmatrix(regionvd, join( [savepath, 'regionvd.tex'] ) )
%
% countryvd = round( [sdvdlow(:,3), sumVarianceDecomp(:,3), sdvdup(:,3)], 4)
% matrix2latexmatrix(countryvd, join( [savepath, 'countryvd.tex'] ) )

% % North America
% disp('North America')
% navd = sumVarianceDecomp(NA, :);
% maxL = length(navd);
% disp('Region Consumption    Country Consumption     Region Output    Country Output')
% disp([mean(navd(2:3:maxL,2)),mean(navd(2:3:maxL,3)),mean(navd(1:3:maxL,2)),mean(navd(1:3:maxL,3))])
%
% mean(navd(3:3:maxL, 2))
% mean(navd(3:3:maxL, 3))
% % Europe
% disp('Europe')
% eurvd = sumVarianceDecomp(EUR, :);
% maxL =length(eurvd);
% [mean(eurvd(2:3:maxL,2)),mean(eurvd(2:3:maxL,3)),mean(eurvd(1:3:maxL,2)),mean(eurvd(1:3:maxL,3))]
% mean(eurvd(3:3:maxL, 2))
% mean(eurvd(3:3:maxL, 3))
%
% % Oceania
% disp('Ocean')
% oceanvd = sumVarianceDecomp(OCEAN, :);
% maxL =length(oceanvd);
% [mean(oceanvd(2:3:maxL,2)),mean(oceanvd(2:3:maxL,3)),mean(oceanvd(1:3:maxL,2)),mean(oceanvd(1:3:maxL,3))]
% mean(oceanvd(3:3:maxL, 2))
% mean(oceanvd(3:3:maxL, 3))
% % Asia dev
% disp('Asia Dev')
% asiadevvd = sumVarianceDecomp(ASIADEVLOP, :);
% maxL =length(asiadevvd);
% [mean(asiadevvd(2:3:maxL,2)),mean(asiadevvd(2:3:maxL,3)),mean(asiadevvd(1:3:maxL,2)),mean(asiadevvd(1:3:maxL,3))]
% mean(asiadevvd(3:3:maxL, 2))
% mean(asiadevvd(3:3:maxL, 3))
% % Asia
% disp('Asia')
% asiavd = sumVarianceDecomp(ASIA, :);
% maxL =length(asiavd);
% [mean(asiavd(2:3:maxL,2)),mean(asiavd(2:3:maxL,3)),mean(asiavd(1:3:maxL,2)),mean(asiavd(1:3:maxL,3))]
% mean(asiavd(3:3:maxL, 2))
% mean(asiavd(3:3:maxL, 3))
%
% % 16-69 Latin America
% disp('Latin America')
% lavd = sumVarianceDecomp(LA, :);
% length(lavd);
% [mean(lavd(2:3:54,2)),mean(lavd(2:3:54,3)),mean(lavd(1:3:54,2)),mean(lavd(1:3:54,3))]
% mean(lavd(3:3:maxL, 2))
% mean(lavd(3:3:maxL, 3))
% % Africa
% disp('Africa')
% africa = sumVarianceDecomp(AFRICA, :);
% maxL = length(africa);
% [mean(lavd(2:3:maxL,2)),mean(lavd(2:3:maxL,3)),mean(lavd(1:3:maxL,2)),mean(lavd(1:3:maxL,3))]
% mean(africa(3:3:maxL, 2))
% mean(africa(3:3:maxL, 3))
% World
% h = fill(fillX(1,:), fillY(1,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% world = plot(xaxis, sumFt(1,:), 'black')
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
% na = plot(xaxis, sumFt(2,:), 'black')
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% saveas(na, join([savepath,'nafactorplot_recessions.jpeg']))
% hold off
% figure
% h = fill(fillX(1,:), fillY(2,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% naregion  = plot(xaxis, sumFt(2,:), 'black')
% saveas(naregion, join([savepath, 'naregionplot.jpeg']))
%% Oceania
% figure
% ocean = plot(xaxis, sumFt(3,:), 'black')
% shade([1970, 1973, 1980, 1982, 1990, 2001, 2008], [1971, 1975, 1981, 1983, 1991, 2002, 2009], 'black')
% hold off
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
% %% Asia Developing
% figure
% h = fill(fillX(1,:), fillY(7,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% asiadev  = plot(xaxis, sumFt(7,:), 'black')
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


