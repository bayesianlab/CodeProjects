function [ lagged_variables ] = vectorized_lags( data_mat, lags)
[row, column] = size(data_mat);
constant = ones(row-lags,1);
lagged_variables = [];
for col = 1:column
    lagged_variables = [lagged_variables,...
        lag_variable(data_mat(:,col), lags)];
end
lagged_variables = [constant lagged_variables];
end

