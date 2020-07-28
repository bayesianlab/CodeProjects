function [draws, parama, paramb] = drawFactorVariance(Factor, stateTransitions, factorVariance, s0, d0)
[NF,T ] = size(Factor);
[~,lags] = size(stateTransitions);
parama = .5.*(s0+T);
paramb = zeros(NF,1);
draws = zeros(NF,1);

for q = 1 :NF
    st = stateTransitions(q,:);
    fv = factorVariance(q);
    [IP,~,~,nv] = initCovar(st, fv);
    if nv ~= 0
        IP = eye(lags);
    end
    [~, H] = FactorPrecision(st, IP, 1./fv, T);
    Hf = H*Factor(q,1:T)';
    paramb(q)=.5*(d0+Hf'*Hf);
    draws(q) = 1/gamrnd(parama, 1./paramb(q) );
end

end

