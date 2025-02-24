function [state, Xt] = kowLagStates(state, lag)
% State is a matrix of row vectors [x1, ...,xT]
[T,K] = size(state);
Xt = zeros( T*lag,K-lag);
for i = 1:lag
    Xt(i, :) = state(:, lag -i + 1:K - i );
end
state = state(:, lag+1:K);

end

