%% Generated from kowGenData()
load('kowy.mat')
load('kowx.mat')
K = size(y);
rng(1)
r0 = 10.*ones(K,1);
v0 = 5;

% [f, b, v] = kowdynfactorgibbs(ys, surx,  b0, inv(B0), v0, r0, 5)


