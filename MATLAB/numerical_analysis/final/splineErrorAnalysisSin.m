function [ order, delta ] = splineErrorAnalysisSin( )

sims = 10;
% interiorPoints = (0:N-1).* (2*pi/N);


error = zeros(sims,1);
order = zeros(sims-1,1);
delta = zeros(sims-1,1);
interiorPoints = 0:2^(-15):2*pi;
points = 1;
for i = 1:sims
    points = 2 * points;
    knots = linspace(0, 2*pi, points);
    h = abs(knots(1) - knots(2))
    y = sin(knots);
    sy = spline(knots, [1,y,1], interiorPoints);
    true = sin(interiorPoints);
    error(i) = max(abs(sy - true));
    if i >= 2
        order(i-1) = log2(error(i-1)/error(i));
        delta(i-1) = h;
    end
end
end

