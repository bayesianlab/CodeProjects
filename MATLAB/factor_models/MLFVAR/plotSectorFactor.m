function [] = plotSectorFactor(factorSeries, factorSeries2ndMoment, xaxis, filename, name)

variance = factorSeries2ndMoment - factorSeries.^2;
sig = sqrt(variance);
upper = factorSeries + 1.5.*sig;
lower = factorSeries - 1.5.*sig;

fillX = [xaxis, fliplr(xaxis)];
fillY = [upper, fliplr(lower)];
facealpha = .3;
COLOR = [1,0,0];
f = figure;
% h=fill(fillX, fillY, COLOR);
% set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
hold on
plot(xaxis,factorSeries, 'Color', 'black', 'LineWidth', 1)
title(name)
hold off
saveas(f, filename)
end

