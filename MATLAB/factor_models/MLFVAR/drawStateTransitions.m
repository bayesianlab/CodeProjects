function [stateTransition] = drawStateTransitions(stateTransition, yt, sigma2, g0, G0)
lags = size(stateTransition,2);
Xt = lagMat(yt,lags)';
eP = eye(lags);
G1 = ((G0\eP) + (Xt'*Xt)/sigma2)\eP;
g1 = G1*( (G0\g0) + (Xt'*yt(lags+1:end)')/sigma2);
notvalid=1;
P0 = initCovar(stateTransition, sigma2);
c=0;
MAXTRIES = 10;
while notvalid == 1
    c = c + 1;
    proposal = tnormrnd(-.99,.99,g1, G1);
    [P1,~,~,notvalid] = initCovar(proposal, sigma2);
    if notvalid == 0
        break
    end
    if c == MAXTRIES
        P1 = 1;
    end

end

alpha = min(0, logmvnpdf(yt(1:lags), zeros(1,lags), P1) - logmvnpdf(yt(1:lags), zeros(1,lags),P0));
if log(unifrnd(0,1)) < alpha
    stateTransition=proposal;
end
end

