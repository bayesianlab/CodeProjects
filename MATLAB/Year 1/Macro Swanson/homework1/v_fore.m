function [ current_period, nxt ] = v_fore( current_period, var_ests,...
    periods_out)
[n c] = size(current_period);
[rows, cols] = size(var_ests);

n_lags = (c-1)/cols;

current_period = vertcat(current_period, zeros(periods_out,c));
next_period = 0;
nxt = zeros(periods_out, cols);

for i = 1:periods_out
    next_period = current_period(i,:)*var_ests;
    nxt(i,:) = next_period;
    first_pass = 0;
    lag_counter = 1;
    for column = 1:rows
        first_pass = first_pass + 1;
        if first_pass == 1
            current_period(i+1,1) = 1;
            continue
        elseif column == (lag_counter*n_lags)
            current_period(i+1,column) = next_period(lag_counter);
            lag_counter = lag_counter + 1;
            if lag_counter > cols
                lag_counter = 1;
            end
            continue
        else
            current_period(i+1,column) = current_period(i,column-1);
        end
            
    end
end



