function [draws, paramb] = drawFactorVariance(Factor, stateTransitions, s0, d0)
[q,T ] = size(Factor);
parama = .5.*(s0+T);
paramb = zeros(q,1);
draws = zeros(q,1);

for t = 1 :q
    fstar = [Factor(t,1)*sqrt(1-stateTransitions(t)^2), Factor(t,2:end)];
    fhat = [0, Factor(t,2:end).*stateTransitions(t)];
    demeaned = (fstar-fhat);    
    paramb(t) = (d0 + demeaned*demeaned');
    draws(t) = 1/gamrnd(parama,1/(.5.*paramb(t)) );
end

end

