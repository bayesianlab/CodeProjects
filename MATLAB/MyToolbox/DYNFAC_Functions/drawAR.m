function [current, alpha, g1, G1] = drawAR(current, yt, sigma2, g0, G0)
% Use lagMat!
% It correctly stores the lags in rows, not lag input, otherwise
% things are upside down.
% The st matrix has the p lags in first column then up to lag 1 in last columns.
% This cannot be easily changed!
[K,T]=size(yt);
lags = size(current,2);

Xt = lagMat(yt,lags)';
ytstar = yt(lags+1:T);
eP = eye(lags);

G1 = ((G0\eP) + (Xt'*Xt)/sigma2)\eP;
G1lower = chol(G1,'lower');

g1 = G1*( (G0\g0') + (Xt'*ytstar')/sigma2);
notvalid=1;
P0 = CalcInitCovar(stateSpaceIt(current,lags), sigma2);
c=0;
MAXTRIES = 10;
while notvalid == 1
    c = c + 1;
    candidate = g1 + G1lower*normrnd(0,1,lags,1);
    [P1,~,~,notvalid] = CalcInitCovar(stateSpaceIt(candidate',lags), sigma2);
    if c == MAXTRIES
        candidate = current';
        P1 = P0;
        break
    end
end

Xp = zeros(lags, lags);
c=lags;
for h = 1:lags
    Xp(:,h) = [zeros(c,1); yt(1:h-1)'];
    c = lags -h; 
end

Scurr = spdiags(repmat(sigma2,T,1), 0, T, T);
Snew = Scurr;


Scurr(1:lags, 1:lags) = P0;
Scurrlower = chol(Scurr, 'lower');
Snew(1:lags, 1:lags) = P1;
Snewlower = chol(Snew,'lower');


Xss = [Xp;Xt];


Snewlowerinv  = Scurrlower\eye(T);
Scurrlowerinv = Snewlower\eye(T);
ystarcurr = Scurrlowerinv'*( yt' - Xss*current');
ystarnew = Snewlowerinv'*( yt' - Xss*candidate);
Num = adjustedlogmvnpdf(ystarnew', Snewlowerinv)+logmvnpdf(candidate', g0, G0)+logmvnpdf(current, g1', G1);
Den = adjustedlogmvnpdf(ystarcurr', Scurrlowerinv)+logmvnpdf(current, g0, G0)+logmvnpdf(candidate', g1', G1);
if ~isscalar(Num-Den)
    error('state transition alpha probability is not scalar.')
end
alpha = min(0, Num - Den);
if log(unifrnd(0,1)) < alpha
    current=candidate';
end
end

