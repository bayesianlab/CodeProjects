function [guess, Bt] = bhhh(guess, parameterizedDll, N, tol, lambda)
[r,J] = size(guess);
for i = 1 : N
    [Fdel, Bt] = parameterizedDll(guess);
    CloseToZero = Fdel'*Fdel;
    if CloseToZero < tol
        break
    end
    dif = Bt\(lambda*Fdel);
    xhat = guess + dif;
    Change = guess - xhat;
    guess = xhat;
end
end

