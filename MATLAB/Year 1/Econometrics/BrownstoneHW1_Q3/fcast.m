function [ output_args ] = fcastvar( X, p )

X_t = vectorized_lags(X, p);
[r,c] = size(X_t);

time_minus_one = X_t(r, :)
[coeffs] = var(X, p);
cur_t = (time_minus_one*coeffs);

update = vectorized_lags(vertcat(X, cur_t), p);
[r,c] = size(update);
cur_t = update(r,:);


end

