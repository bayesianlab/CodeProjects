function [quant] = drawPhiG(omARStar, yt, xt,beta,deltas, obsv, delta0,Delta0)
[K,T] = size(yt);
[~,p] = size(deltas);
[~,lags] = size(deltas);
[L0, ~] = initCovar(deltas, obsv);
Clower = chol(L0,'lower');
Cinv = Clower\eye(p);

Delta0delta0 = Delta0*delta0';
yp = yt(:,1:p);
xp = xt(1:p, :);
mut = reshape(xt*beta,K,T);

epsilont = (yt - mut);
Lagepsilont = lagMat(epsilont, p)';
epsilont = epsilont(:,p+1:end)';

% Propose a candidate

proposalVariance = (Delta0 +( Lagepsilont'*Lagepsilont)./obsv)\eye(p);
proposalMeanN = proposalVariance*(Delta0delta0 + (Lagepsilont'*epsilont)./obsv);
S0draw = initCovar(deltas, obsv);
S0drawlower= chol(S0draw,'lower');
S0drawlowerinv = S0drawlower\eye(lags);
Yp1 = ((S0drawlowerinv'*yp') - (S0drawlowerinv'*xp)*beta)';
Y1 = [Yp1'; (epsilont - (Lagepsilont*omARStar'))./obsv];
Yp2 = ((Cinv'*yp') - (Cinv'*xp)*beta)';
Y2 = [Yp2'; (epsilont - (Lagepsilont*deltas'))./obsv];

proposalDist = @(x)logmvnpdf(x, proposalMeanN', proposalVariance);

Num=MHphi(Y1, S0drawlowerinv, omARStar', delta0, Delta0)+proposalDist(deltas);
Den=MHphi(Y2, Cinv, deltas', delta0, Delta0)+proposalDist(omARStar);
alpha = min(0, Num-Den);
quant = alpha + proposalDist(omARStar);

end

