function [ index ] = findIndex( row, value )
for i = 1:length(row)
    if row(i) == value
        index = i
    end
end


end

