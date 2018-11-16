%% Generated from kowGenData()
clear;
clc;
[y, surx] = kowGenData();

% load('kowy.mat')
% load('kowx.mat')
K = size(y,1);
rng(1)
r0 = 10.*ones(K,1);
v0 = 5;
b0 = 1;
B0 = 1;
[f, f2 b, b2, v, v2] = kowdynfactorgibbs(y, surx,  b0, inv(B0), v0,...
    r0, 5000, 1500)


