function [] = plotSectorFactor(factorSeries, factorSeries2ndMoment, xaxis, name, varargin)

variance = factorSeries2ndMoment - factorSeries.^2;
sig = sqrt(variance);
upper = factorSeries + 2.*sig;
lower = factorSeries - 2.*sig;

fillX = [xaxis, fliplr(xaxis)];
fillY = [upper, fliplr(lower)];
facealpha = .3;
COLOR = [1,0,0];
f = figure;
h=fill(fillX, fillY, COLOR);
set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
hold on
plot(xaxis,factorSeries, 'Color', 'black', 'LineWidth', 1)

if nargin > 4
    title(name)
    filename = varargin{1};
    saveas(f, filename)
end
hold off
end

