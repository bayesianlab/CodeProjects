function [draws] = drawFactorVariance(Factor, stateTransitions, s0, d0)
[q,T ] = size(Factor);
parama = .5.*(s0+T);
draws = zeros(q,1);
for t = 1 :q
    fstar = [Factor(q,1)*sqrt(1-stateTransitions(q)^2), Factor(q,2:end)];
    fhat = [0, Factor(q,2:end).*stateTransitions(q)];
    demeaned = (fstar-fhat);
    paramb = .5.*(d0 + demeaned*demeaned');
    draws(t) = 1/gamrnd(parama,1/paramb);
end
end

