function [p] = drawPhi(yt, xt,beta,deltas, obsv, Cinv )
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
c=0;
unitCircle = 2;
while unitCircle >=1
    c = c + 1;
    draw = proposalMeanN + chol(proposalVariance,'lower')*normrnd(0,1,lags,1);
    Phi = [draw'; eye(lags-1), zeros(lags-1,1)];
    unitCircle = sum(abs(eig(Phi)) >= 1);
    if c == 50
        draw= deltas';
        break
    end
end
S0draw = initCovar(draw');
S0drawlower= chol(S0draw,'lower');
S0drawlowerinv = S0drawlower\eye(lags);
LL = @(phi, P0lowerinv)MHphi(y1(:), xt(1:lags,:), beta, obsv, ystar2', Xstar', phi, P0lowerinv);
proposalDist = @(x)logmvnpdf(x, proposalMeanN', proposalVariance);
alpha = min(0, (LL(draw, S0drawlowerinv)+proposalDist(deltas)) - ...
    (LL(deltas', Cinv)+proposalDist(draw'))   );
if log(unifrnd(0,1)) < alpha
    p = draw;
else
    p = deltas;
end
end

