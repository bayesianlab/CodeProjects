function [ jac ] = dBigF2( dydt, t, y, h )
derivative =  dydt(t(2), y);
[row, ~] = size(derivative);
jac = ones(row,1) - (h*.5*derivative);
end

