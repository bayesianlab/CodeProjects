function [notj] = nonSquareNotj(arows, acols)
notj = ones(arows,acols);
for i = 1:arows
    for j = 1:acols
        if i == j
            notj(i,j) = 0;
        end 
    end
if i == acols
    break
end
end
end