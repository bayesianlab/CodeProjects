function [guess, Bt] = bhhh(guess, parameterizedDll, N, tol)
[J,c] = size(guess);
for i = 1 : N
    [Fdel, Bt] = parameterizedDll(guess);
    dif = reshape(Bt\Fdel, J,c)';
    xhat = guess + dif;
    Change = guess - xhat;
    CloseToZero = Change'*Change;
    guess = xhat;
    if CloseToZero < tol
        break
    end
end
end

