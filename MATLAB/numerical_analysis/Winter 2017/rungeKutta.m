clear 
clc
yt = @(t) t.^2 + 2*t + 1 - .5*exp(t);
yInit = .5;
tSpan = [0,4];
h = 1;
odeErrorAnalysis1(8, h, tSpan, yInit, @ypt, yt)



yInit = [2;1];
tSpan = [0,10];
h= .5;
vdp = runge4(tSpan, yInit, @dVanDerPol, .1);
hold on
plot(vdp(:,1), vdp(:,2))
plot(vdp(:,1), vdp(:,3))
odeErrorAnalysis2(7, h, tSpan, yInit, @dVanDerPol)