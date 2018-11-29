function [] = kowMcc(Sims, burnin)
% [y, surx] = kowGenData();
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end
load('surx.mat');
load('kowy.mat');
K = size(y,1);
rng(1)
r0 = 10.*ones(K,1);
v0 = 5;
b0 = 1;
B0 = 1;
[f, f2 b, b2, v, v2] = kowdynfactorgibbs(y, surx, v0, r0, Sims, burnin)

fname = createDateString('kow_')
save(fname)
end

