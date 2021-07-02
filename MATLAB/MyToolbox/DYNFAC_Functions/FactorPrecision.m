function [P,H] = FactorPrecision(params, P0, precision, T)
% Factor precision is column
% Factors are assumed Ft = [ Fwt
 %                     Frt
 %                      Fct ]
 % F = Vectorized (F1, F2,...,FT)
[K,columns] = size(params);
lags =columns;
dees = -K*lags:K:0;
newp = [-params,ones(K,1),];
H = spdiags(repmat(newp,T,1), dees, T*K, T*K);
Sinv = spdiags(repmat(precision, T,1), 0, K*T, K*T);
P = H'*Sinv*H;
end

