function [quant] = drawPhiG(omARStar, yt, xt,beta,deltas, obsv, Cinv)
[K,T] = size(yt);
[~,lags] = size(deltas);
deltasPriorMean = zeros(1,lags);
deltasPriorPre = eye(lags);
deltasPriorsM = deltasPriorPre*deltasPriorMean';
y1 = yt(:,1:lags);
mut = reshape(xt*beta,K,T);
ystar = yt - mut;
ystar2 = ystar(:,lags+1:end);
Xstar = lagMat(ystar, lags);
% Propose a candidate
proposalVariance = (deltasPriorPre +( Xstar*Xstar'./obsv))\eye(lags);
proposalMeanN = proposalVariance*(deltasPriorsM + (Xstar*ystar2')./obsv);

S0draw = initCovar(deltas');
S0drawlower= chol(S0draw,'lower');
S0drawlowerinv = S0drawlower\eye(lags);
LL = @(phi, P0lowerinv)MHphi(y1(:), xt(1:lags,:), beta, obsv, ystar2', Xstar', phi, P0lowerinv);
proposalDist = @(x)logmvnpdf(x, proposalMeanN', proposalVariance);
alpha = min(0, (LL(omARStar, S0drawlowerinv)+proposalDist(deltas)) - ...
    (LL(deltas', Cinv)+proposalDist(omARStar'))   );
quant = alpha + proposalDist(omARStar');
end

