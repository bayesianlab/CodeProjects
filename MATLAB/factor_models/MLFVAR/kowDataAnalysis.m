clear; clc;
load('Result_kowDataVar1.mat')
xaxis = 1962:2014;
sig2 = sumFt2 - sumFt.^2;
sig = sqrt(sig2);
upper = sumFt + 2.*sig;
lower = sumFt - 2.*sig;
% fillX = [xaxis, fliplr(xaxis)];
% fillY = [upper, fliplr(lower)];
% facealpha = .3;
% LW = .75;
% COLOR = [1,0,0];
% h = fill(fillX(1,:), fillY(1,:), COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
% hold on
% p1 = plot(xaxis, sumFt(1,:), 'Color', 'black', 'LineWidth', 1);
% title('World')
% hold off

betasig2 = sumBeta2 - sumBeta.^2;
betasig = sqrt(betasig2);
upperBeta = 1.5*betasig + sumBeta;
lowerBeta = sumBeta  - 1.5*betasig;
roundBeta = round([lowerBeta, sumBeta, upperBeta], 3);
matrix2latexmatrix(roundBeta, 'kowbeta.tex')

matrix2latexmatrix(round(sumVarianceDecomp,3), 'kowvdecomp.tex')
