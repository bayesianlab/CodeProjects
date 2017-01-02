function [ solutionsStorage, solutions ] = newtonArc(SystemEqn, JacobSys,...
    JacobP, X_0, alpha, alphaEnd, alphaStep, newtonIterations,...
    totalIterations, ds, tol )

solutions = newtonWithParameter(SystemEqn, JacobSys, X_0, alpha, alphaEnd,...
    alphaStep, newtonIterations, tol);
iterations = 0;
if isempty(solutions)
    return
end
nSols = size(solutions)
X_0 = solutions(nSols(1), 2:3)';
alpha = solutions(1);
% Determine Approximate Tangent Vector at a solution    
xCur = [X_0;alpha];
solutionsStorage(1, 1:3) = xCur';
solutionCounter = 1;
iJacobian = inv(JacobSys(xCur, alpha));
alphaDot = sqrt(1 + norm(iJacobian*JacobP(xCur, alpha)))^(-1);
xDot = (iJacobian * JacobP(xCur, alpha))' * alphaDot;
directions = [xDot, alphaDot];
dNorm = norm(directions);
directions = directions ./ dNorm;
% directions(3) = -directions(3);

while iterations < totalIterations
    iterations = iterations + 1;
    
    xCur = solutionsStorage(solutionCounter, 1:3)';

    % Predictor
    xTan = xCur + directions'*ds;
   
    % Newton solution
    j = 0;
    while j < newtonIterations 
        j = j + 1;
        jacob = [JacobSys(xTan, alpha), JacobP(xTan, alpha); directions];
        xDelalphaDel = -linsolve(jacob,...
            [SystemEqn(xTan(1:2), xTan(3));normalEqn(directions, xTan, xCur, ds)]);
        xTan = xTan  + xDelalphaDel;
        systemEval = [SystemEqn(xTan(1:2), xTan(3));...
            normalEqn(directions, xTan, xCur, ds)];
        if norm(systemEval) < tol
            solutionCounter = solutionCounter + 1;
            solutionsStorage(solutionCounter, 1:3) = xTan';
            break
        end
    end
    alpha = xTan(3);
    J = [JacobSys(xTan(1:2), alpha), JacobP(xTan(1:2), alpha);directions];
    directions = (linsolve(J, [0;0;1])');
    dNorm = norm(directions);
    directions = directions ./ dNorm;
%     directions(3) = -directions(3);
end
solutionsStorage = solutionsStorage(2:solutionCounter,:);
end

