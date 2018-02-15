function [alpha, beta] = epsilon(a, b, mu, Linv)
[J, ~]= size(Linv);
alpha = a- mu;
beta = b -mu;
tfa = ismember(-inf,a);
tfb = ismember(inf,b);
for j = 1:J
    test = Linv(j, j ~= 1:J);
    res = sum(0==test);
    if  res == J-1 && alpha(j) ~= -inf
       if tfa
           alpha(j) = Linv(j, j)*alpha(j);
       end
    else
        alpha(j) = -inf;
    end 
end

end   


