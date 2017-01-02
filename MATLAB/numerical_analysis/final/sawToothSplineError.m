function [ order ] = sawToothSplineError(  )

sims = 10;
error = zeros(sims,1);
order = zeros(sims-1,1);
delta = zeros(sims-1,1);
interiorPoints = 0:2^(-15):2*pi;
for i = 1:sims
    knots = linspace(0, 2*pi, 2^i);
    h = abs(knots(1) - knots(2));
    y = sawTooth(knots);
    interpolation = spline(knots, [-1,y,-1], interiorPoints);
    truth = sawTooth(interiorPoints);
    error(i) = max(abs(truth - interpolation))
    hold on
    plot(interiorPoints, interpolation)    
    if i >= 2
        order(i-1) = log2(error(i-1) / error(i));
        delta(i-1) = h;
    end
end
figure(2)
plot(log2(delta), order)
end

