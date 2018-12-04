function [  ] = kow2Period( Sims, burnin)
load('kow2p.mat')
if ischar(Sims)
    Sims = str2num(Sims);
end
if ischar(burnin)
    burnin = str2num(burnin);
end

[f, f2, b, v] = kowdynfactorgibbs(kowp1y, kowp1x,  v0, r0,  S, bn);
[f, f2, b, v] = kowdynfactorgibbs(kowp2y, kowp2x,  v0, r0,  S, bn);
[f, f2, b, v] = kowdynfactorgibbs(kowpapery, kowpaperx,  v0, r0,  S, bn);
fname = createDateString('k2p_')
save(fname)
end

