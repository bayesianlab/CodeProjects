function [ s ] = lagOut( dMat, lags, iter, s )
if nargin <3
    iter = 1;
    
end
lenMat = length(dMat);
if iter == 1
    s = zeros(length(dMat) - lags,1);
end

tmp =  dMat(iter:(lenMat-lags), 1);
s = [s, tmp];


if lags == 1
    dMat(1:iter) = [];
    s(:,1) = dMat;
    return 
end
s = lagOut(dMat, lags - 1, iter + 1, s);

end

