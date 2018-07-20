% Simulate Economic data
clear;clc;
N=250;
lgdpg = zeros(N,1);
lgdpg = zeros(N,1);
for i = 2 : N
    lgdpg(i) = .3 + .99*lgdpg(i-1) + normrnd(0, .1)
end

plot(lgdpg)