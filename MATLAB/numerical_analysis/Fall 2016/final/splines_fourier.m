clear
clc
N = 2^3;
half = N/2;
delta = 2*pi/N;
k = 0:N-1;
xk = k.*delta;
y1 = sin(xk);
% [px, fy1] = fftInterpolate(y1, 2^10);
% true = sin(px);
% hold on
% plot(px, fy1)
% plot(px, true)
% xlabel('0 to 2\pi')
% ylabel('y')

% [order, delta] = splineErrorAnalysisSin()
% plot(log2(delta), order)
% xlabel('log_2 Delta')
% ylabel('log_2 Error(i-1) / Error(i) ')

% sawToothSplineError()
% y = sawTooth(linspace(0,2*pi, 2));
% yy = spline(linspace(0,2*pi, 2), [-1, y, -1], linspace(0,2*pi, 1000));

% plot(linspace(0, 2, 100), periodic(linspace(0,2, 100)))

[o, e, d] = periodicErrorAnalysis()



