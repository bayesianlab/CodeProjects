function [lagmat] = lagInput(X, lags)
% Returns a matrix that is lagged:
% lagmat1 = Xt-1
% lagmat2 = Xt-2
% .
% . 
% .
% lagmat lags = Xt-lags

[K,T]= size(X);
lagmat = zeros(K*lags,T-lags);
inds  =1:K;
incr = 0;
for h = lags:(-1):1
    rows = inds + (h-1)*K;
    incr = incr + 1;
    cols = incr:T-h;
    lagmat(rows,:) = X(:, cols);    
end
end

