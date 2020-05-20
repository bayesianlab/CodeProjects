function [current] = drawAR(current, yt, sigma2, g0, G0)
lags = size(current,2);
Xt = lagMat(yt,lags)';
eP = eye(lags);
G1 = ((G0\eP) + (Xt'*Xt)/sigma2)\eP;
G1lower = chol(G1,'lower');
g1 = G1*( (G0\g0) + (Xt'*yt(lags+1:end)')/sigma2);
notvalid=1;

P0 = CalcInitCovar(stateSpaceIt(current,lags), sigma2);
c=0;
MAXTRIES = 10;
while notvalid == 1
    c = c + 1;
    candidate = g1 + G1lower*normrnd(0,1,lags,1);
    [P1,~,~,notvalid] = CalcInitCovar(stateSpaceIt(candidate,lags), sigma2);
    if notvalid == 0
        break
    end
end



alpha = min(0, logmvnpdf(yt(1:lags), zeros(1,lags), P1) - logmvnpdf(yt(1:lags), zeros(1,lags),P0));
if log(unifrnd(0,1)) < alpha
    current=candidate;
end
end

