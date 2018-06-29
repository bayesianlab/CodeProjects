function [] = factorModelGibbs(y, X, initGamma, initFactorVar, aInit)

% sample b
% sample a f
%% sample a
%% sample f
% sample variance
[K, T] = size(y);
IT = eye(T);
[nFacs, ~] = size(initGamma);
IR = eye(nFacs);
FactorVarDiag= kron(IT, initFactorVar);
Idiagonal = full(spdiags(ones(T*nFacs,1), 0, T*nFacs, T*nFacs));
GammaOffDiagonal = kron(full(spdiags(ones(T,1),-1,T,T)), -initGamma);
offBlockDiag =  Idiagonal + GammaOffDiagonal;
Sinv = offBlockDiag' * FactorVarDiag  * offBlockDiag;
Sinv = inv(Sinv);
factormean = zeros(1, T*nFacs);
f = reshape(mvnrnd(factormean, Sinv), nFacs, T);

    
end

