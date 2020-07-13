function [alpha] = drawPhiJ(yt, xt, beta, deltas, obsv, delta0, Delta0)
% T is kept in columns
% This is an equation by equation function, not meant for 
% multidimensional yt's
% This code has been checked
[K,T] = size(yt);
[~,p] = size(deltas);
L0 = initCovar(deltas, obsv);
[Clower,pd]=chol(L0,'lower');
if pd ~= 0
    Clower = eye(pd);
end
MAXN= 75;
Cinv = Clower\eye(p);

yp = yt(:,1:p);
xp = xt(1:p, :);

mut = reshape(xt*beta,K,T);
epsilont = (yt - mut);
Lagepsilont = lagMat(epsilont, p)';
epsilont = epsilont(:,p+1:end)';

% Propose a candidate
proposalVariance = ((Delta0\eye(p)) +( Lagepsilont'*Lagepsilont)./obsv)\eye(p);
proposalMeanN = proposalVariance*(( Delta0\delta0')+ (Lagepsilont'*epsilont)./obsv);
L = chol(proposalVariance,'lower');
c=0;
unitCircle = 2;
while unitCircle >=1
    c = c + 1;
    proposal = (proposalMeanN + L*normrnd(0,1,p,1))';
    Phi = [proposal; eye(p-1), zeros(p-1,1)];
    unitCircle = sum(abs(eig(Phi)) >= 1);
    if c == MAXN
        proposal= deltas;
        break
    end
end


S0draw = initCovar(proposal, obsv);
S0drawlower= chol(S0draw,'lower');
S0drawlowerinv = S0drawlower\eye(p);

Yp1 = ((S0drawlowerinv'*yp') - (S0drawlowerinv'*xp)*beta)';
Y1 = [Yp1'; (epsilont - (Lagepsilont*proposal'))./obsv];
Yp2 = ((Cinv'*yp') - (Cinv'*xp)*beta)';
Y2 = [Yp2'; (epsilont - (Lagepsilont*deltas'))./obsv];

proposalDist = @(x)logmvnpdf(x, proposalMeanN', proposalVariance);

Num=MHphi(Y1, S0drawlowerinv, proposal', delta0, Delta0)+proposalDist(deltas);
Den=MHphi(Y2, Cinv, deltas', delta0, Delta0)+proposalDist(proposal);
alpha = min(0, Num-Den);

end

