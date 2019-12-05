function [piOmega] = piOmegaStar(s2, stateTransitions, Factor, s0,d0)
[q,T ] = size(Factor);
[~,lags] = size(stateTransitions);
parama = .5.*(s0+T);
paramb = zeros(q,1);
piOmega = zeros(q,1);
IP = eye(lags);
for t = 1 :q
    [L0, ssterms] = initCovar(stateTransitions(t,:));
    [~, H] = FactorPrecision(ssterms, L0, 1./s2(t), T);
    H(1:lags,1:lags) = (chol(L0,'lower')\IP)';
    Hf = H*Factor(t,1:T)';
    paramb(t)=.5*(d0+Hf'*Hf);
    piOmega(t) = logigampdf(s2(t), parama, paramb(t));
end
end

