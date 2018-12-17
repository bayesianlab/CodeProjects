function [ ll ] = kowLogLike( countryguess, ydemu, StatePrecision, obsPrecision )
speyet = speye(T);
O = diag(obsPrecision);
Oa = O*countryguess;
kOa = kron(speyet, Oa);
Middle =(StatePrecision +  kron(speyet, countryguess'*O*countryguess)) \ eye(T);
P = spdiags(repmat(obsPrecision, T,1),0,K*T, K*T) - kOa* Middle *kOa';

ll = kowOptimLogMvnPdf(ydemu, P);

end

