function [cons] = consumption_policy( A, k, n)
alpha = .33;
beta= .99;

cons = log(A*(k^alpha)*(n^(1-alpha)) * ( 1 - (alpha*beta)));

end

