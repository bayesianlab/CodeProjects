function [  ] = kow2Period( )
load('kow2p.mat')
[f, f2, b, v] = kowdynfactorgibbs(kowp1y, kowp1x,  v0, r0,  2000, 200);
[f, f2, b, v] = kowdynfactorgibbs(kowp2y, kowp2x,  v0, r0,  2000, 200);
[f, f2, b, v] = kowdynfactorgibbs(kowpapery, kowpaperx,  v0, r0,  2000, 200);
fname = createDateString('k2p_')
save(fname)
end

