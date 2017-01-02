function [ solutionCurve ] = newtonWithParameter(sys, jacob, guess, alpha,...
    alphaEnd, alphaStep, maxIterationsPerParameter, tolerance)
iterationCount = 0;
solutionCount = 0;
X_0 = guess;
while alpha < alphaEnd
    iterationCount = iterationCount + 1;
    if abs(det(jacob(X_0, alpha))) < 10^(-15) || abs(det(jacob(X_0, alpha))) > 10^15
        fprintf('Matrix singular. Iterations stopped.\n')
        solutionCurve = NaN; 
        return
    end
    X_0 = newtonStep(sys, jacob, X_0, alpha);
    functionValue = sys(X_0, alpha)
    if norm(functionValue) < tolerance
        solutionCount = solutionCount + 1;
        solutionCurve(solutionCount, 1) = alpha;
        solutionCurve(solutionCount, 2:3) = X_0';
        fprintf('Solution found with parameter value = %.3f\n', alpha)
        fprintf('Verification: F(x, y) = %.3f\n', functionValue)
        fprintf('\n\n')
        alpha = alpha +  alphaStep;
        iterationCount = 0;
    end
    if iterationCount > maxIterationsPerParameter
        fprintf('Max iteration count reached. Passing.\n')
        alpha = alpha + alphaStep;
        continue
    end
end
end

