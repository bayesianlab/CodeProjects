clear;clc; 
rng(1)
g = .5;
T = 50;
K = 10;
P0 = initCovar(g, 1);
P = FactorPrecision(g, P0, 1, T);
LPinv = chol(P,'lower')\eye(T);
f1 = (LPinv'*normrnd(0,1,T,1))';
f2 = (LPinv'*normrnd(0,1,T,1))';

A = unifrnd(0,1,K,2);
A= tril(A);

[R,C] = size(A);

for c = 1:C
    for b = 1:C
        if b == c
            A(c,c) = 1;
        end
    end
end
y = A*[f1;f2] + normrnd(0,1,K,T);


test_multifactor(yt) 