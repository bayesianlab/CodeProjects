function [] = kowMcc(Sims, burnin, ReducedRuns)
% [y, surx] = kowGenData();
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end
if ischar(ReducedRuns)
    ReducedRuns = str2num(ReducedRuns)
end
load('kow.mat');
K = size(kowy,1);
rng(1)
r0 = 10.*ones(K,1);
v0 = 5;
b0 = 1;
B0 = 1;
[f,f2,ml] = kowdynfactorgibbs(kowy, kowx,  v0, r0, Sims, burnin, ReducedRuns)

fname = createDateString('kow_')
save(fname)
end

