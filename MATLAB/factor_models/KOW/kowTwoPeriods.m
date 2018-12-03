load('kow.mat');
rng(1);
K = size(kowy,1);
r0 = 10.*ones(K,1);
v0 = 5;
b0 = 1;
B0 = 1;
[f, f2, b, b2, v, v2] = kowdynfactorgibbs(kowy, kowx,  v0, r0,  20, 8);