function [ current_period, nxt ] = forecast( current_period, var_ests,...
    periods_out)
[n c] = size(current_period);
[rows, cols] = size(var_ests);

current_period = vertcat(current_period, zeros(periods_out,c));
next_period = 0;
nxt = zeros(periods_out, cols);

for i = 1:periods_out
    next_period = current_period(i,:)*var_ests;
    nxt(i,:) = next_period;
    current_period(i+1,1) = 1;
    current_period(i+1,2) = next_period(1);
    current_period(i+1,3) = current_period(i,2);
    current_period(i+1,4) = next_period(2);
    current_period(i+1,5) = current_period(i,4);
    current_period(i+1,6) = next_period(3);
    current_period(i+1,7) = current_period(i,6);
    
end

end

