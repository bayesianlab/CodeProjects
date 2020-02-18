function [draws, parama, paramb] = drawFactorVariance(Factor, stateTransitions, factorVariance, s0, d0)
[NF,T ] = size(Factor);
[~,lags] = size(stateTransitions);
parama = .5.*(s0+T);
paramb = zeros(NF,1);
draws = zeros(NF,1);
IP = eye(lags);
for q = 1 :NF

    [L0, ssterms] = initCovar(stateTransitions(q,:), factorVariance(q));
    [~, H] = FactorPrecision(ssterms, L0, 1./factorVariance(q), T);
    H(1:lags,1:lags) = (chol(L0,'lower')\IP)'*sqrt(factorVariance(q));
    Hf = H*Factor(q,1:T)';
    paramb(q)=.5*(d0+Hf'*Hf);
%     Hf'*Hf
%     moment1 = paramb(q)/(parama-1);
%     moment2 = (paramb(q)^2)/( ((parama-1)^2)*(parama-2) );
%     statevariances=[moment1, moment2]
    draws(q) = 1/gamrnd(parama, 1./paramb(q) );
end
end

