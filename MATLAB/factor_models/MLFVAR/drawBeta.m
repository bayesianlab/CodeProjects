function [b,v,V] = drawBeta(yt,  xi, deltas,...
    prmean, prcovar, obsVariance)
[K,T] = size(yt);
[~,lags] = size(deltas);
[rx,dimx] = size(xi);
yinit = [zeros(K,lags), yt(:,1:lags)];
yinit = lagMat(yinit, lags);
Ly = lagMat(yt,lags);
Ly = [yinit, Ly];
sx = zeros(rx, dimx);
for g = 1:lags
    t = zeros(lags-(g-1), dimx);
    tx = deltas(g).*[t;xi];
    sx = sx + tx(g:T+(g-1),:);
end
xstar = xi-sx;
ystar = yt - deltas*Ly;
xstarystar = xstar'*ystar';
B0inv = diag((diag(prcovar).^(-1)));
V = ((xstar'*xstar)./obsVariance+ B0inv)\eye(dimx) ;
prs = (B0inv*prmean);
v = V* (((xstarystar)./obsVariance) + prs);
b = v + chol(V,'lower')*normrnd(0,1, dimx,1);
end

