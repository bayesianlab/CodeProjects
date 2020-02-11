%% Simulation Study Results Used in Paper
% Feb. 10, 2020 Checked
% clear;clc;
% simpath = 'SimulationStudyResults/Results_Timebreak_Files/';
% files = dir(join([simpath,'*.mat']));
% x =natsortfiles({files.name});
% length(x)
% N = floor(length(x)/2)
% beg = 1:N;
% G = length(beg);
% c=40;
% for g = 1:N
%     set1 = x{G+ g}
%     datapath = join([simpath,set1]);
%     ml1 = load(datapath, 'ml');
%     set2 = x{g}
%     datapath = join([simpath,set2]);
%     ml2 = load(datapath, 'ml');
%     sumMls(g,2) = ml1.ml + ml2.ml;
%     sumMls(g,1) = c;
%     c = c + 1;
% end
% [a,b]=max(sumMls)
% tml = load( 'SimulationStudyResults/Result_totaltime.mat', 'ml');
% tml=tml.ml;
% hold on
% plot(sumMls(:,1),sumMls(:,2))
% plot(sumMls(:,1),ones(size(sumMls,1),1).*tml)
