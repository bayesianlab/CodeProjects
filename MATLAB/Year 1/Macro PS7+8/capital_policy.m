function [ k ] = capital_policy( A, k, n )
alpha = .33;
beta= .99;

k = log((alpha*beta*A*(k^alpha)*n^(1-alpha)));

end

