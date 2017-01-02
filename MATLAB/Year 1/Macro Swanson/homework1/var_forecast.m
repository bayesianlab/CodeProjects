function [ current_period, nxt ] = var_forecast( current_period, var_ests, periods_out)
[n c] = size(current_period);
[rows, cols] = size(var_ests);

n_lags = (c-1)/cols;

current_period = vertcat(current_period, zeros(periods_out,c));
next_period = 0;
nxt = zeros(periods_out, cols);

for i = 1:periods_out
    next_period = current_period(i,:)*var_ests;
    nxt(i,:) = next_period;

    current_period(i+1,1) = 1;
    current_period(i+1,2) = next_period(1);
    current_period(i+1,3) = current_period(i,2);
    current_period(i+1,4) = current_period(i,3);
    current_period(i+1,5) = current_period(i,4);
    current_period(i+1,6) = current_period(i,5);
    current_period(i+1,7) = current_period(i,6);
    current_period(i+1,8) = current_period(i,7);
    current_period(i+1,9) = current_period(i,8);
    current_period(i+1,10) = current_period(i,9);
    current_period(i+1,11) = current_period(i,10);
    current_period(i+1,12) = current_period(i,11);
    current_period(i+1,13) = current_period(i,12);
    
    current_period(i+1,14) = next_period(2);
    current_period(i+1,15) = current_period(i,14);
    current_period(i+1,16) = current_period(i,15);
    current_period(i+1,17) = current_period(i,16);
    current_period(i+1,18) = current_period(i,17);
    current_period(i+1,19) = current_period(i,18);
    current_period(i+1,20) = current_period(i,19);
    current_period(i+1,21) = current_period(i,20);
    current_period(i+1,22) = current_period(i,21);
    current_period(i+1,23) = current_period(i,22);
    current_period(i+1,24) = current_period(i,23);
    current_period(i+1,25) = current_period(i,24);
        
    current_period(i+1,26) = next_period(3);
    current_period(i+1,27) = current_period(i,26);
    current_period(i+1,28) = current_period(i,27);
    current_period(i+1,29) = current_period(i,28);
    current_period(i+1,30) = current_period(i,29);
    current_period(i+1,31) = current_period(i,30);
    current_period(i+1,32) = current_period(i,31);
    current_period(i+1,33) = current_period(i,32);
    current_period(i+1,34) = current_period(i,33);
    current_period(i+1,35) = current_period(i,34);
    current_period(i+1,36) = current_period(i,35);
    current_period(i+1,37) = current_period(i,36);
    

    
end

end

