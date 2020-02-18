function [quant] = drawPhiG(omARStar, yt, xt,beta,deltas, obsv, delta0,Delta0)
[K,T] = size(yt);
[~,p] = size(deltas);
[~,lags] = size(deltas);
[L0, ~] = initCovar(deltas, obsv);
Cinv = chol(L0,'lower')\eye(p);
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
Yp1 = ((S0drawlowerinv*yp') - (S0drawlowerinv*xp)*beta)';
Y1 = [Yp1'; epsilont - (Lagepsilont*deltas')];
Yp2 = ((Cinv*yp') - (Cinv*xp)*beta)';
Y2 = [Yp2'; epsilont - (Lagepsilont*omARStar')];

LL = @(yt1,  phi)MHphi(yt1, obsv, phi, delta0, Delta0);
proposalDist = @(x)logmvnpdf(x, proposalMeanN', proposalVariance);
alpha = min(0, (LL(Y2, omARStar')+proposalDist(deltas)) - ...
    (LL(Y1, deltas')+proposalDist(omARStar)));
quant = alpha + proposalDist(omARStar);

end

