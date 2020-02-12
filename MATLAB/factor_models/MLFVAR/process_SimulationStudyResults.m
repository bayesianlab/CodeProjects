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