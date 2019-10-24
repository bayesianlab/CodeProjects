function [X] = rows2diag(x, K)
[T,dimx] = size(x);
indices = 1:K;
X = zeros(K*T, dimx*K);
for j = 1:T
    select = indices + (j-1)*K;
    X(select,:) = kron(eye(K), x(j,:));
end

end

