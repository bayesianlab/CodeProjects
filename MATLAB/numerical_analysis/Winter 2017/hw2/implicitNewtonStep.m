function [ X_0, c ] = implicitNewtonStep( guess, F, J, epsilon, maxIterations,...
    dispOn, realRoot)
iterationCount = 0;
X_0 = guess;

while iterationCount < maxIterations
    iterationCount = iterationCount + 1;
    
    if abs(det(J(X_0))) < 10^(-14) || abs(det(J(X_0))) > 10^14
        fprintf('Matrix singular. Iterations stopped.\n')
        return
    end
    if iterationCount == maxIterations
        fprintf('Did not converge to solution.\n')
        return
    end
    eN = norm(realRoot - X_0)^2;
    H = -linsolve(J( X_0), F(X_0));
    X_Next = X_0 + H;
    X_0 = X_Next;
    if dispOn == 1
        fprintf('Value of function at iteration %i \n', iterationCount)
        disp(F(X_0))
    end
    if norm(F(X_0)) < epsilon 
        fprintf('Convergence to solution. Iterations = %i \n', iterationCount)
        fprintf('F(X_0)\n')
        disp(F(X_0))
        fprintf('Solutions \n')
        disp(X_0)
        return
    end
    eNext = norm(realRoot - X_0);
    c(iterationCount) = eNext;
end
end
