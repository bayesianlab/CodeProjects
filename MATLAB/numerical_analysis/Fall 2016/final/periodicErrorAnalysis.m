function [ order, error, delta] = periodicErrorAnalysis(  )

sims =14;
error = zeros(sims,1);
order = zeros(sims-1,1);
delta = zeros(sims-1,1);
interiorPoints = 0:2^(-18):1;
length(interiorPoints)
endPointDerivative = pi/3;
for i = 1:sims
    h = .5^(i);
    knots = 0:h:1;
    y = periodic(knots);
    interpolation = spline(knots, ...
        [endPointDerivative,y, endPointDerivative], interiorPoints);
    truth = periodic(interiorPoints);
    error(i) = max(abs(truth - interpolation));
    hold on
    plot(interiorPoints, interpolation)    
    if i >= 2
        order(i-1) = log2(error(i-1) / error(i));
        delta(i-1) = h;
    end
end
plot(interiorPoints,truth, '--')
figure(2)
plot(log2(delta), order)
xlabel('log_2 Delta')
ylabel('log_2 Error(i-1) / Error(i)')

end

