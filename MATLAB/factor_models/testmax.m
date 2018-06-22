function [L] = testmax(b,y,X)
K = length(b);
[T, ~] =size(X); 
L = zeros(T,K);
for i = 1:K
    delb = zeros(K,1);
    delb(i) = 1;
    for t = 1:T
        Q = X(t,:)' * X(t,:);
        L(t,i) = ((y(t) * X(t,:)) - (b'* Q) ) * delb;
    end
end
end
