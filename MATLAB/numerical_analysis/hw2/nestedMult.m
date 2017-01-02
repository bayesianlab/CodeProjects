function[ evaled ] = nestedMult(coefs, val)
n = length(coefs);
evaled = coefs(n);
if n > 1
    while n > 1 
      n=n-1;
      evaled = evaled * val + coefs(n);
    end

else
    disp('Error')
end
end