function [S,Sinv] =...
    createFactorBandedDiag(initGamma, initFactorVar, IT)
[T, ~] = size(IT);
[nFacs,~]= size(initFactorVar);
FactorVarDiag= kron(IT, initFactorVar);
Idiagonal = full(spdiags(ones(T*nFacs,1), 0, T*nFacs, T*nFacs));
GammaOffDiagonal = kron(full(spdiags(ones(T,1),-1,T,T)), -initGamma);
offBlockDiag =  Idiagonal + GammaOffDiagonal;
S = offBlockDiag' * FactorVarDiag  * offBlockDiag;
Sinv = inv(S);
end

