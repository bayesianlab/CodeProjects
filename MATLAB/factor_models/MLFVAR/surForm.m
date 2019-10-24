function [X] = surForm(stackedX, K)
indices = 1:K;
[KT,dx] = size(stackedX);
T = KT/K;
X = zeros(KT, dx*K);
block =kron(eye(K), ones(1,dx));
for j = 1:T
    select = indices + (j-1)*K;
    X(select,:) =block.*repmat(stackedX(select,:),1,K);
end
end

