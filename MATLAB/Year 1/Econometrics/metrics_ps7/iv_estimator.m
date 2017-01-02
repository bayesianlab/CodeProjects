function [ betaIV] = iv_estimator( Z, X, y )
% Insturmental Variable Esitmator
betaIV = inv(Z'*X) * Z'*y;
end

