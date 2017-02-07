function [ newY0 ] = implicitNewtonStep(ts, yGuess, F, DF, fnq, Dfnq, nSteps, h,...
    epsilon, maxIterations)
iterationCount = 0;
[~, col] = size(yGuess);
yNew = yGuess(nSteps+1, 1:col);
while iterationCount < maxIterations
    iterationCount = iterationCount + 1;
    if iterationCount == maxIterations
        fprintf('Did not converge\n\n')
        newY0 = [yPrevious;yNew];
        return
    end
    yPrevious = yGuess(1:nSteps, 1:col);
    funcVal = F(ts, yNew, yPrevious, fnq, h);
    jacobian = DF(Dfnq, ts, yNew, h);
    H = -linsolve(jacobian, funcVal);
    canidate = yNew + H';
    if norm(canidate - yNew) <= epsilon
        newY0 = [yPrevious;yNew];
        return
    end
    yNew = canidate;
end
newY0 = canidate;
end
