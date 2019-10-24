function [lm] = lagX(X, k, lags)
[K,T]= size(X);
c = 0;
Im = zeros(lags*K, T- k*lags);
inds  =1:K;
for i = 1:lags
    rows = inds + (i-1)*K;
    start = 1 + (i-1)*k;
    lm(rows, :) = X(:,start:T-(lags*K) +(c*K));
    c= c+1;
end


end

