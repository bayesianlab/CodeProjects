function [P,H] = FactorPrecision(params, P0, precision, T)
% Factor precision is column
% Row 1 of params is [pw 0 0 pr 0 0 pc 0 0 ]
% Factors are Ft = [ Fwt
 %                     Frt
 %                      Fct ]
 % F = Vectorized (F1, F2,...,FT)
[nFactors,columns] = size(params);
lags =columns/nFactors;
dees = (0:lags-1)*nFactors;
exdiags = dees;
pdiags = -repmat(spdiags(params, exdiags), T,1);
dees = (0:lags)*nFactors;
pdiags = [pdiags, ones(nFactors*T,1)];
H = spdiags(pdiags, dees ,nFactors*(T-lags), nFactors*T);
H = [spdiags(ones(nFactors*lags,1),0, nFactors*lags, nFactors*T);H];
Sinv = spdiags(repmat(precision, T,1), 0, nFactors*T, nFactors*T);
Sinv(1:nFactors*lags, 1:nFactors*lags) = P0\eye(nFactors*lags);
P = H'*Sinv*H;
end

