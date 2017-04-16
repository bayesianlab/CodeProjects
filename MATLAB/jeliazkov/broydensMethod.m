function [ xnp1 ] = broydensMethod(F, guess, guessJ, fEps, xEps, tau, maxIter,...
    maxBackSteps)
i = 0;
guessJI = guessJ;
F0 = F(guess);
fprintf('Intial function value=\n')
disp(F0)
normF0 = norm(F0);
totalIterations = 0;
while i < maxIter 
    i = i + 1;
    F0 = F(guess);
    delX = -(tau.*(guessJI*F0));
    xnp1 = guess + delX;
    F1 = F(xnp1);
    normF1 = norm(F1);
    if  normF1 < fEps
        totalIterations = totalIterations + i;
        fprintf('\nFunction value sufficiently small, F(X)=\n')
        disp(F1)
        fprintf('\nTotal Iterations= %i\n', totalIterations)
        break
    elseif norm(xnp1 - guess) < xEps
        totalIterations = totalIterations + i;
        fprintf('\nX not changing, F(X)=\n')
        disp(F1)
        fprintf('\nTotal Iterations= %i\n', totalIterations) 
        break
    end
    if normF1 > normF0  || isnan(normF1) 
        fprintf('\nOvershot: F(X) =\n')
        disp(F1)
        fprintf('Backstepping...\n')
        j = 0 ;
        while j < maxBackSteps
            totalIterations = totalIterations + 1;
            j = j + 1;
            delX = .5.*delX;
            xnp1 = guess + delX;
            F1 = F(xnp1);
            normF1 = norm(F1);
            fprintf('Backstep X\n')
            disp(xnp1)
            if normF1 < normF0
                fprintf('Broke out of backstep with X= \n')
                disp(xnp1)
                break
            end
        end
        if j == maxBackSteps
            xnp1 = guess;
        end
    end
    delF = F1 - F0;
    guess = xnp1;
    % Sherman Morrison
    jacobianInvTimesDelF = guessJI*delF;
    num = (delX - jacobianInvTimesDelF)* (delX'*guessJI);
    den = (delX'*guessJI* delF);
    jacobianUpdate = guessJI + (num./den);
    guessJI = jacobianUpdate;
    fprintf('Function value at iteration %i\n', i)
    disp(F1)
    fprintf('Using X value\n')
    disp(xnp1)
end


end

