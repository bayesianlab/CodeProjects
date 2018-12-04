function [  ] = kow2Period( S, bn)
load('kow2p.mat')
if ischar(S)
    S = str2num(S);
end
if ischar(bn)
    bn = str2num(bn);
end

[f, f2, stf, b, v] = kowdynfactorgibbs(kowp1y, kowp1x,  v0, r0,  S, bn);
[f, f2, stf, b, v] = kowdynfactorgibbs(kowp2y, kowp2x,  v0, r0,  S, bn);
[f, f2, stf, b, v] = kowdynfactorgibbs(kowpapery, kowpaperx,  v0, r0,  S, bn);
fname = createDateString('k2p_')
save(fname)
end

