clear
clc
tSpan = 1:.01:1.2
f = @(x) exp(x.^2 -1);
% plot(tSpan, f(tSpan))
% [x', f(x)']

practiceFnq(1, 1)
tSpan = [1, 1.2];
h = .05;
y1 = 1
getInitialPoints(8, tSpan, y1, @practiceFnq, h)

