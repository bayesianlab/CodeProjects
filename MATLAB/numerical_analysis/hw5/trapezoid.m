function [ sum ] = trapezoid( lowLim, upLim, intervals,  func)
h = (upLim - lowLim) / intervals;
sum = (func(lowLim) + func(upLim)) * 0.5;
for i = 1:(intervals - 1)
    x = lowLim + (i * h);
    sum = sum + func(x);
end
sum = sum * h;
end

