function [guess, Bt] = bhhhProbit(guess, parameterizedDll, N, tol, lambda)
[r,c] = size(guess);
for i = 1 : N
    guess = reshape(guess, r,c);
    [Fdel, Bt] = parameterizedDll(guess);
    CloseToZero = Fdel'*Fdel;
    if CloseToZero < tol
        break
    end
    dif = Bt\(lambda*Fdel);
    guess = guess(:);
    xhat = guess + dif;
    guess = xhat;
end
end