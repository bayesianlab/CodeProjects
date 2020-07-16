function [b,v,V, ystar, xstar, Cinv] = drawBeta(yt,  xt,  deltas, obsVariance, P0, prmean, prprecision)
[K,T] = size(yt);
[~,lags] = size(deltas);
[rx,dimx] = size(xt);
x1 = xt(1:lags,:);
x2 =xt(lags+1:end,:);
Cinv = chol(P0./obsVariance,'lower')\eye(lags);
y1 = yt(:,1:lags)';
y2=yt(:,lags+1:end);
xstar1=Cinv'*x1;
ystar1=Cinv'*y1;

prmean = prmean.*ones(1,dimx);
iyt = lagMat(yt, lags);
ystar = [reshape(ystar1,K,lags),y2 - deltas*iyt];


sx = zeros(rx-lags, dimx);
for g = 1:lags    
    sx = sx+deltas(g).* xt(g:T-lags + (g-1),:);
end


xstar = [xstar1;x2-sx];

xstarystar = xstar'*ystar';
B0inv = prprecision.*eye(dimx);
V = (((xstar'*xstar)./obsVariance)+ B0inv)\eye(dimx);
prs = (B0inv*prmean');
v = V* (((xstarystar)./obsVariance) + prs);
b = v + chol(V,'lower')*normrnd(0,1, dimx,1);
end

