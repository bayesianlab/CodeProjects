function [val] = testcode(x0, y, SigmaInverse, S, Sinv, It, K)

x0K = kron(It, x0);
term = SigmaInverse*x0K;
Wood = SigmaInverse - (term*((Sinv + x0K'*term)\term'));
term = y'*Wood;
Deriv = kron(speye(K), x0) + kron(x0, speye(K));
term = kron(term, term) * kron(S(:), Deriv);
F = zeros(1,K);
for k = 1:K
    R = reshape(Deriv(:,k), K, K);
    F(k) = trace(Wood*kron(S, R));
end
val = term - F;
end

