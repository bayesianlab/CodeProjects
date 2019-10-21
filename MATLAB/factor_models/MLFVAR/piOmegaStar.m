function [piOmega] = piOmegaStar(s2, stateTransitions, Factor, s0,d0)
[q,T ] = size(Factor);
parama = .5.*(s0+T);
paramb = zeros(q,1);
piOmega = zeros(q,1);

for t = 1 :q
    fstar = [Factor(t,1)*sqrt(1-stateTransitions(t)^2), Factor(t,2:end)];
    fhat = [0, Factor(t,2:end).*stateTransitions(t)];
    demeaned = (fstar-fhat);    
    paramb(t) = .5.*(d0 + demeaned*demeaned');
    piOmega(t) = logigampdf(s2(t), parama, paramb(t));
end
end

