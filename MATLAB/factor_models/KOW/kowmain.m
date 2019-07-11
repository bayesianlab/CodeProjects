%% Generated from kowGenData()
clear;
clc;

load('kow.mat')
K = size(kowy,1);
rng(1)
r0 = 10.*ones(K,1);
v0 = 5;
b0 = 1;
B0 = 1;


[f, f2, ml] = kowdynfactorgibbs(kowy, kowx,  v0, r0,  3, 1, 3)


