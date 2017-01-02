function [ linearError, errors ] = sawToothErrorAnalysis(  )
N = 1:10;

points = 2.^N;
errors = zeros(length(N), 1);
linearError = zeros(length(N-1), 1);
for i = N
    n = points(i);
    h = 2*pi/n;
    x = h.*(0:(n-1));
    y = sawTooth(x);
    [px, fy ] = fftInterpolate(y, (2*n));
    yy = sawTooth(px);
    errors(i) = max(abs(yy - fy));
    if i >= 2
        linearError(i-1) = log(errors(i-1)/errors(i));
    end
end
plot(linearError)
end

