function [newvalue, alpha] = drawPhi(yt, xt, beta, deltas, obsv, delta0, Delta0)
% T is kept in columns
% This is an equation by equation function, not meant for 
% multidimensional yt's
% This code has been checked
[K,T] = size(yt);
[~,p] = size(deltas);
[L0, ~] = initCovar(deltas);
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
c=0;
unitCircle = 2;
while unitCircle >=1
    c = c + 1;
    draw = (proposalMeanN + chol(proposalVariance,'lower')*normrnd(0,1,p,1))';
    Phi = [draw; eye(p-1), zeros(p-1,1)];
    unitCircle = sum(abs(eig(Phi)) >= 1);
    if c == 50
        draw= deltas;
        break
    end
end
S0draw = initCovar(draw');
S0drawlower= chol(S0draw,'lower');
S0drawlowerinv = S0drawlower\eye(p);

Yp1 = ((S0drawlowerinv*yp) - (S0drawlowerinv*xp)*beta)';
Y1 = [Yp1; epsilont - (Lagepsilont*deltas')];
Yp2 = ((Cinv*yp) - (Cinv*xp)*beta)';
Y2 = [Yp2; epsilont - (Lagepsilont*draw')];

LL = @(yt1,  phi)MHphi(yt1, obsv, phi, delta0, Delta0);
proposalDist = @(x)logmvnpdf(x, proposalMeanN', proposalVariance);
alpha = min(0, (LL(Y2, draw)+proposalDist(deltas)) - ...
    (LL(Y1, deltas')+proposalDist(draw'))  );
if log(unifrnd(0,1)) < alpha
    newvalue = draw';
else
    newvalue = deltas;
end
end