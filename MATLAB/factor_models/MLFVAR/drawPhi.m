function [] = drawPhi(yt,ybar, deltas, obsv )
[K,T] = size(yt);
[~,lags] = size(deltas);
deltasPriorMean = zeros(1,lags);
deltasPriorPre = eye(lags);
deltasPriorsM = deltasPriorPre*deltasPriorMean';
ebar = [zeros(K, lags),ybar];
Xbar = lagMat(ebar, lags);
proposalVariance = (deltasPriorPre + Xbar*Xbar')\eye(lags);
proposalMean = proposalVariance*(deltasPriorsM + (Xbar*ybar')./obsv);
draw = proposalMean + chol(proposalVariance,'lower')*normrnd(0,1,lags,1);
proposalDist = @(x)logmvnpdf(x, proposalMean', proposalVariance);
Likelihood = @(g)logmvnpdf(g, zeros(1,K), eye(K));
e = ybar - draw'*Xbar;
sse = e*e';
Likelihood = Likelihood((ebar*ebar')./obsv)


% [rx,dimx] = size(xi);
% yinit = [zeros(K,lags), yt(:,1:lags)];
% yinit = lagMat(yinit, lags);
% Ly = lagMat(yt,lags);
% Ly = [yinit, Ly];
% sx = zeros(rx, dimx);
% for g = 1:lags
%     t = zeros(lags-(g-1), dimx);
%     tx = deltas(g).*[t;xi];
%     sx = sx + tx(g:T+(g-1),:);
% end
% xstar = xi-sx;
% ystar = yt - deltas*Ly;
% xstarystar = xstar'*ystar';
% B0inv = diag((diag(prcovar).^(-1)));
% V = ((xstar'*xstar)./obsVariance+ B0inv)\eye(dimx) ;
% prs = (B0inv*prmean);
% v = V* (((xstarystar)./obsVariance) + prs);
% b = v + chol(V,'lower')*normrnd(0,1, dimx,1);
end

