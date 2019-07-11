function [  ] = kowPlotFactor( trueFt, Ft, Ft2, Regions, Countries )
standardErrors = sqrt(Ft2 - Ft.^2);
standardErrorsPM = 1.5.*standardErrors

% Plot World Factor
figure(1)
hold on 
plot( trueFt(1,1:end-1), 'k', 'LineWidth', 2)
plot( Ft(1,:), 'b')
plot( Ft(1,:) + standardErrorsPM(1,:), 'r--')
plot(Ft(1,:) - standardErrorsPM(1,:), 'r--')
hold off


for r = 1:Regions
    figure(r+1)
    hold on
    plot( trueFt(r + 1,1:end-1), 'k', 'LineWidth', 2)
    plot( Ft(r + 1,:), 'b')
    plot(Ft(r + 1,:) + standardErrorsPM(r + 1,:), 'r--')
    plot(Ft(r + 1,:) - standardErrorsPM(r + 1,:), 'r--')
hold off
end

for c = 1:Countries
    in = c +Regions +1;
    figure(in)
    hold on
    plot( trueFt(in,1:end-1), 'k', 'LineWidth', 2)
    plot( Ft(in,:), 'b')
    plot(Ft(in,:) + standardErrorsPM(in,:), 'r--')
    plot(Ft(in,:) - standardErrorsPM(in,:), 'r--')
hold off
end
end

