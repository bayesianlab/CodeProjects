function [ xnp1 ] = broydensMethod(F, guessJ, guess, tol, maxIter)
i = 0;
guessJI = inv(guessJ);
while i < maxIter % norm(F(guess)) > tol
    i = i + 1
        xnp1 = guess - (guessJI*F(guess))
        delF = F(xnp1) - F(guess);
        delX = xnp1- guess;
        % Sherman Morrison
        den = (delX'*guessJI * delF)^(-1)
        num = (delX - guessJI *delF)*delX'*guessJI
        guessJI = guessJI + (num./den);
        guess = xnp1
  
    
end


end

