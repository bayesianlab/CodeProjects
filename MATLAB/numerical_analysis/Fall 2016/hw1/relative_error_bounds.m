clear
clc
size = 100;
rounding = 2;
noise = roundk(normrnd(0,10,size,1), rounding*3);
roundedNoise = roundk(noise, rounding);
error = (noise - roundedNoise) ./ noise;

x = 1:size;
boundary = ones(size,1) * 5*(10^(7-rounding));
plot(x, abs(error), '-', x, boundary, '-')
ylim = 1;
