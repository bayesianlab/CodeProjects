clear;
clc
i = 1;
while i < 1000
    if 1 + .5^(i)  == 1
        s = sprintf(['Smallest e such that 1 + 2^e != 1' ... 
        ' is: \n\n\te = %i'], i);
        s
        break 
    else
        i = i + 1;
    end
end

if 2^53 + 1 == 2^53
  disp('True, largest integer 2^53')
end

