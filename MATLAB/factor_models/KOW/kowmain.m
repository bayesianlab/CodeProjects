%% Generated from kowGenData()
clear;
clc;
% [y, surx] = kowGenData();

load('kowy.mat')
load('surx.mat')
% load('kowy2.mat')
% load('kowx2.mat')
% y = kowy2;
% surx = kowx2;
clear kowy2
clear kowx2
K = size(y,1);
rng(1)
r0 = 10.*ones(K,1);
v0 = 5;
b0 = 1;
B0 = 1;
[f, f2, b, b2, v, v2] = kowdynfactorgibbs(y, surx,  v0, r0,  20, 8);


