function [Yt, Xt] = lagYt(Yt, lag)

[n,K] = size(Yt);
start = 2;
Xt = zeros(n-lag, K*lag + 1);
for i = 1:lag
    Xt(:, start:K*i+1) = Yt(lag -i + 1:n - i ,:);
    start = K*i + 2;
end
Yt = Yt(lag+1:n, :);
[xn, ~] = size(Xt);
Xt(:,1) = ones(xn, 1);
end

