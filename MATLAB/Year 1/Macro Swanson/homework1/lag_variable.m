function [ lagged_variables ] = lag_variable( data_series, num_lags)
[n,c] = size(data_series);
lagged_variables = zeros(n - num_lags, num_lags);

for i = 0:num_lags-1
   lagged_variables(:, i+1) = data_series(num_lags - i : (n - i - 1)); 
end
end

