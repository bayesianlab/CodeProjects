function [lm] = lagMat(X, lags)
% Takes row vectors returns
% E 1:T-lags
% E 2:T-lags+1
% ...
% Where E= [e1; e2;...eK] 
[K,T]= size(X);
c = 0;

lm = zeros(K*lags,T-lags);
inds  =1:K;
for h = 1:lags
    rows = inds + (h-1)*K;
    lm(rows,:) = X(:, h:T-lags+c);
    c = c+1;
end
end

