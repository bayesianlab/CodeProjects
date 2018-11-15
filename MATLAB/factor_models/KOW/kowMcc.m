function [] = kowMcc(Sims, burnin)
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    Sims = str2num(burnin);
end



[y, surx] = kowGenData();
K = size(y,1);
rng(1)
r0 = 10.*ones(K,1);
v0 = 5;
b0 = 1;
B0 = 1;
[f, f2 b, b2, v, v2] = kowdynfactorgibbs(y, surx,  b0, inv(B0), v0, r0, Sims, burnin)
save('kowoutput.mat')

end

