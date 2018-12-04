clear;clc;
load('kow.mat');
rng(1);
K = size(kowy,1);
r0 = 10.*ones(K,1);
v0 = 5;
b0 = 1;
B0 = 1;
kowp1y = kowy(:,1:46);
kowp1x = kowx(1:46*180,:);
kowp2y = kowy(:, 47:end);
kowp2x = kowx((47*180)+1:end,:);
kowpapery = kowy(:,1:30);
kowpaperx = kowx(1:(30*180),:);
save('kow2p.mat')
% [f, f2, b, b2, v, v2] = kowdynfactorgibbs(kowy, kowx,  v0, r0,  20, 8);