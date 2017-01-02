function [ minValue ] =...
    gainBestFit( R_0, phi_0, series,expectations, nGains, dispOn)

gains = linspace(0, .3, nGains);

storeDifferences = zeros(nGains,1);
for g = 1:nGains
    [storeDifferences(g),~] = learning(R_0, phi_0, gains(g), series, ...
        expectations);
end
[~ ,indexOfMin ] = min(storeDifferences);
minValue = gains(indexOfMin);
if dispOn ==1
    plot(gains, storeDifferences)
    xlabel('Gains g\in [0,.3]')
    ylabel('Function Value')
    title('Difference in expectations in survey data versus learning')
end

