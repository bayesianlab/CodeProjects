clear;clc;
load('run_date_08_Jan_2019_18_59_25_smallt.mat')
nfactors = size(Factor,1);
sdev = sqrt(f2 - f.^2);

for i = 1:nfactors
    fig = figure(i);
    hold on
    plot(Factor(i,1:end-1), 'Color', 'blue', 'LineWidth', 1)
    plot(f(i,:), 'Color', 'black')
    plot(f(i,:) + sdev(i,:), 'Color', 'red', 'LineStyle', '--', 'LineWidth', .25)
    plot(f(i,:) - sdev(i,:), 'Color', 'red', 'LineStyle', '--', 'LineWidth', .25)
end