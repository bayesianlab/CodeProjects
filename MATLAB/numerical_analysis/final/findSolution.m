function [ X_Next ] = findSolution( X_0, alpha, alphaEnd, alphaStep,...
    maxIterations, tolerance)
i = 0;
test = 1;
solutions = newtonWithParameter(X_0, alpha, alphaEnd, alphaStep,...
    maxIterations, tolerance);
while test > tolerance
    i = i + 1;
    X_Next = newtonStep(X_0, alpha);
    X_0 = X_Next;
    test = norm(System(X_Next, alpha));
    if i > maxIterations
        fprintf('No solution found. Error')
        return
    end
end
end

