clear;clc;
% load('Covid/Covid.mat')
% RunHdfvar(10000,2000, 1, '/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/Covid', 'Covid.mat', 'test', '~/CodeProjects/MATLAB/factor_models/MLFVAR/TestDir')
load('TestDir/Result_Covid_test_17_Apr_2020_18_33_21.mat')
% coviddata = covidImport('CovidDataRaw.csv');
% LevelCovid(coviddata, yt)
% logcoviddata = log(coviddata+1);
% coviddiffdata = diff(logcoviddata,1,2);
% mus = mean(coviddiffdata,2);
% sigmas = std(coviddiffdata,[],2);
% cod = sigmas.*yt + mus;
% cod = (coviddata(:,3:end) .* exp(cod)) -1; 
% cod = coviddata(:,2:end-1) * exp(cod) 

% cod = coviddata(:,1:end-1) .* exp(cod)


% hold on
% size(cod)
% size(coviddata)
% plot(cod(1,:))
% plot(yhat(1,:))

% beta0 = mean(storeVAR,3);
% PredictOut = 3;
% obsPrecision = mean(storeObsPrecision,2);
% currobsmod = mean(storeOM,3);
% stateTransitions = mean(storeStateTransitions,3);
% factorVariance = mean(storeFactorVar,2);
% predSims = 5;
% PosteriorPredictive = zeros(K, predSims, PredictOut);
% HdfvarPredict(PredictOut, yt, Xt, Ft, InfoCell, obsPrecision, currobsmod, stateTransitions,...
%     factorVariance, beta0, B0inv,  a0, A0inv, v0, r0, g0, G0, s0, d0, predSims, PosteriorPredictive)



% coviddata = covidImport('CovidDataRaw.csv');
