function [ y ] = output( A, k, n )
alpha = .33;
y = log(A*(k^alpha) * n^(1-alpha));

end

