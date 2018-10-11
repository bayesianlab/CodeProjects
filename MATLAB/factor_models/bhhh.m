function [guess, Bt] = bhhh(guess, parameterizedDll, N, tol, lambda)
for i = 1 : N
    [Fdel, Bt] = parameterizedDll(guess);
    if Fdel'*Fdel < tol
        break
    end
    dif = Bt\(lambda*Fdel);
    xhat = guess + dif;
    Change = guess - xhat;
    guess = xhat;
end
end

