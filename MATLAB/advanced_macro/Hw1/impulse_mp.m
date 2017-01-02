function [ ynow ] = impulse_mp(  F, G, periods, MP_shock)
[row, ~, ~] = size(F);
ynow = zeros(row, periods + 1);

epsilon_t = [0,MP_shock, 0]';
for i = 1:periods
    ynow(1:row, i + 1 ) =  F * ynow(1:7, i) + (G * epsilon_t);
    epsilon_t = zeros(3,1);
end
ynow = ynow(1:row, 2:(periods+1));
