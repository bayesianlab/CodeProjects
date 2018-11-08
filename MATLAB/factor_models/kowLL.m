function [ll] = kowLL(countryguess, ydemu, StatePrecision, obsPrecision, K, T)
speyet = speye(T);
O = diag(obsPrecision);
Oa = O*countryguess;
kOa = kron(speyet, Oa);
Middle =(StatePrecision +  kron(speyet, countryguess'*diag(obsPrecision)*countryguess)) \ eye(T);
P = spdiags(repmat(obsPrecision, T,1),0,K*T, K*T) - kOa* Middle *kOa';
ll = kowOptimLogMvnPdf(ydemu, P);
end

