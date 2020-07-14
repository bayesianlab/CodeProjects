function [alpha] = drawAR_Jstep(current, yt, sigma2, g0, G0, g1bar, G1bar)
% Use lagMat!
% It correctly stores the lags in rows, not lag input, otherwise
% things are upside down.
% The st matrix has the p lags in first column then up to lag 1 in last columns.
% This cannot be easily changed!
[K,T]=size(yt);
lags = size(current,2);
Xt = lagMat(yt,lags)';


candidate = g1bar + chol(G1bar,'lower')*normrnd(0,1,lags,1);

Xp = zeros(lags, lags);
c=lags;
for h = 1:lags
    Xp(:,h) = [zeros(c,1); yt(1:h-1)'];
    c = lags -h; 
end

Scurr = spdiags(repmat(sigma2,T,1), 0, T, T);
Snew = Scurr;
P0 = CalcInitCovar(stateSpaceIt(current,lags), sigma2);

P1 = CalcInitCovar(stateSpaceIt(candidate',lags), sigma2);


Scurr(1:lags, 1:lags) = P0;
Scurrlower = chol(Scurr, 'lower');
Snew(1:lags, 1:lags) = P1;
Snewlower = chol(Snew,'lower');


Xss = [Xp;Xt];

ystarcurr = Scurrlower*( yt' - Xss*current');
ystarnew = Snewlower*( yt' - Xss*candidate);

Snewlowerinv  = Scurrlower\eye(T);
Scurrlowerinv = Snewlower\eye(T);
Num = adjustedlogmvnpdf(ystarnew', Snewlowerinv)+logmvnpdf(candidate', g0, G0)+logmvnpdf(current, g1bar', G1bar);
Den = adjustedlogmvnpdf(ystarcurr', Scurrlowerinv)+logmvnpdf(current, g0, G0)+logmvnpdf(candidate', g1bar', G1bar);
if ~isscalar(Num-Den)
    error('state transition alpha probability is not scalar.')
end
alpha = min(0, Num - Den);

end

