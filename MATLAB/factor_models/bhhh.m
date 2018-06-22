function [guess, Bt] = bhhh(guess, parameterizedDll, N, tol)
for i = 1 : N
    [Fdel, Bt] = parameterizedDll(guess);
    dif = Bt\Fdel;
    xhat = guess + dif;
    Change = guess - xhat;
    CloseToZero = Change'*Change;
    guess = xhat;
    if CloseToZero < tol
        break
    end
end
end

