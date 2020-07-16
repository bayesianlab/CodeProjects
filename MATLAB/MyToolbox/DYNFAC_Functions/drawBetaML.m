function [pib, ystar, xstar, Cinv] = drawBetaML(betaStar, yt,  xt, deltas, obsVariance, P0, b0, B0inv)
[K,T] = size(yt);
[~,lags] = size(deltas);
[rx,dimx] = size(xt);

x1 = xt(1:lags,:);
x2 =xt(lags+1:end,:);
Cinv = chol(P0,'lower')\eye(lags);
y1 = yt(:,1:lags)';
y2=yt(:,lags+1:end);
xstar1=Cinv'*x1;
ystar1=Cinv'*y1;
iyt = lagMat(yt, lags);
ystar = [reshape(ystar1,K,lags),y2 - deltas*iyt];
sx = zeros(rx-lags, dimx);

for g = 1:lags    
    sx = sx+deltas(g).* xt(g:T-lags + (g-1),:);
end
xstar = [xstar1;x2-sx];
xstarystar = xstar'*ystar';
B0inv = eye(dimx).*B0inv;
b0 = b0.*ones(1,dimx);
V = ((xstar'*xstar)./obsVariance+ B0inv)\eye(dimx) ;
prs = (B0inv*b0');
v = V* (((xstarystar)./obsVariance) + prs);
pib = logmvnpdf(betaStar', v', V);
end

