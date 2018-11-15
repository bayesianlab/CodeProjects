function [ sigmaDraw ] = drawSigmaDiag( shapedy, shapedmu, priora, priorb )
[K,T] = size(shapedy);
sigmaDraw = zeros(K,1);
parama = priora + T;
for k = 1:K
    resid = shapedy(k,:) - shapedmu(k,:);
    sigmaDraw(k) = resid*resid';
    sigmaDraw(k) = 1/gamrnd(parama, 1/(priorb + sigmaDraw(k)));
end
end

