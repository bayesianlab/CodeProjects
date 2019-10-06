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
% clear;clc;
% savepath = '~/GoogleDrive/statespace/';
% simpath = 'TBKOW/OldResults/';
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
% 
% tbaxis = 1967:2010;
% 
% 
% mlfull = load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/TBKOW/Result_kowTimes100.mat', 'ml');
% mlfull = mlfull.ml;
% hold on 
% tbp = plot(tbaxis, ones(length(tbaxis),1).*mlfull);
% plot(tbaxis, sumMls(:,2))
% [a,b] = max(sumMls)
% saveas(tbp, join([savepath,'tbp.jpeg']))
%%%%%%%%%%%%%%%%%%%%%%%%
%% Application KOW dataset
clear;clc;
savepath = '~/GoogleDrive/statespace/';
load('BigKowResults/Result_kowz_03_Oct_2019_07_13_54.mat')
NA = 1:9;
OCEAN = 10:15;
LA = 16:69;
EUR = 70:123;
AFRICA = 124:144;
ASIADEVELOP = 145:162;
ASIA = 163:180;



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


filevardec= fopen('navd.txt', 'w+');
navd =  varianceDecomp(NA,:);
for j = 1:size(navd,1)
    fstr = sprintf('%.3f %.3f %.3f \n', navd(j,1), navd(j,2), navd(j,3));
    fprintf(filevardec, fstr);
end
fclose(filevardec');
filevardec= fopen('ocvd.txt', 'w+');
ocvd =  varianceDecomp(OCEAN,:);
for j = 1:size(ocvd,1)
    fstr = sprintf('%.3f %.3f %.3f \n', ocvd(j,1), ocvd(j,2), ocvd(j,3));
    fprintf(filevardec, fstr);
end
fclose(filevardec');
filevardec= fopen('lavd.txt', 'w+');
lavd =  varianceDecomp(LA,:);
for j = 1:size(lavd,1)
    fstr = sprintf('%.3f %.3f %.3f \n', lavd(j,1), lavd(j,2), lavd(j,3));
    fprintf(filevardec, fstr);
end
fclose(filevardec');
filevardec= fopen('eurvd.txt', 'w+');
eurvd =  varianceDecomp(EUR,:);
for j = 1:size(eurvd,1)
    fstr = sprintf('%.3f %.3f %.3f \n', eurvd(j,1), eurvd(j,2), eurvd(j,3));
    fprintf(filevardec, fstr);
end
fclose(filevardec');
filevardec= fopen('afvd.txt', 'w+');
afvd =  varianceDecomp(AFRICA,:);
for j = 1:size(afvd,1)
    fstr = sprintf('%.3f %.3f %.3f \n', afvd(j,1), afvd(j,2), afvd(j,3));
    fprintf(filevardec, fstr);
end
fclose(filevardec');
filevardec= fopen('asdvd.txt', 'w+');
asdvd =  varianceDecomp(ASIADEVELOP,:);
for j = 1:size(asdvd,1)
    fstr = sprintf('%.3f %.3f %.3f \n', asdvd(j,1), asdvd(j,2), asdvd(j,3));
    fprintf(filevardec, fstr);
end
fclose(filevardec');
filevardec= fopen('asvd.txt', 'w+');
asvd =  varianceDecomp(ASIA,:);
for j = 1:size(asvd,1)
    fstr = sprintf('%.3f %.3f %.3f \n', asvd(j,1), asvd(j,2), asvd(j,3));
    fprintf(filevardec, fstr);
end
fclose(filevardec');

% Average var dec.
mean(varianceDecomp(NA,2))
mean(varianceDecomp(OCEAN,2))
mean(varianceDecomp(LA,2))
mean(varianceDecomp(EUR,2))
mean(varianceDecomp(AFRICA,2))
mean(varianceDecomp(ASIADEVELOP,2))
mean(varianceDecomp(ASIA,2))


%% World
% figure
% world = plot(xaxis, sumFt(1,:), 'black');
% saveas(world, join([savepath, 'world.jpeg']))



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
% hold on
% naregion  = plot(xaxis, sumFt(5,:), 'black')
% saveas(naregion, join([savepath, 'naregionplot.jpeg']))
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
% figure
% asia  = plot(xaxis, sumFt(8,:), 'black')
% saveas(asia, join([savepath, 'asia.jpeg']))
% figure
% h = fill(fillX(1,:), fillY(8,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% asia_stderrs  = plot(xaxis, sumFt(8,:), 'black')
% saveas(asia_stderrs, join([savepath, 'asia_stderrs.jpeg']))

%% Asia Developing
% figure
% h = fill(fillX(1,:), fillY(7,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% asiadev_stderrs  = plot(xaxis, sumFt(7,:), 'black')
% saveas(asiadev_stderrs, join([savepath, 'asiadev_stderrs.jpeg']))
% figure
% asiadevelop  = plot(xaxis, sumFt(7,:), 'black')
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
% saveas(mexico, join([savepath,'mexicofactor.jpeg']))
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


