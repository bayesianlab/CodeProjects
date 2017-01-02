function [ shifted_row] = shiftRowRight( val, row )

len = length(row);
shifted_row = [val row(1:(len-1))]


end

