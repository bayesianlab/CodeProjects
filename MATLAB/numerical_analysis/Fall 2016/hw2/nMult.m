function [ output ] = nMult( points, coefs, val )
n = length(coefs);
output = coefs(n);
if n > 1
    while n > 1
        n=n-1;
        output = output*(val - points(n)) + coefs(n);
    end
else
    output = '-1';
    disp('Error, n too small.')
    return
end 

end

