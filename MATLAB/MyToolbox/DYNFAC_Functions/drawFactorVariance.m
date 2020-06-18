function [draws, parama, paramb] = drawFactorVariance(Factor, stateTransitions, factorVariance, s0, d0)
[NF,T ] = size(Factor);
[~,lags] = size(stateTransitions);
parama = .5.*(s0+T);
paramb = zeros(NF,1);
draws = zeros(NF,1);
IP = eye(lags);
for q = 1 :NF
    [~, H] = FactorPrecision(stateTransitions(q,:), IP, 1./factorVariance(q), T);
    Hf = H*Factor(q,1:T)';
    paramb(q)=.5*(d0+Hf'*Hf);
    draws(q) = 1/gamrnd(parama, 1./paramb(q) );
end

end

