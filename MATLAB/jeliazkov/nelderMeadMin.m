function [ minVal, minX ] = nelderMeadMin(guess, fun, maxIter, initialSimplexSize,...
    fTol, dispOn)
alpha = 1;
beta = 2;
gamma = .5;
delta = .5;

[r,c] = size(guess);
lambda = repmat(.5,r,1);
nDimP1 = r + 1;
unitVector = eye(r).*initialSimplexSize;

initialSimplex(:,:) =  zeros(r, nDimP1);
initialSimplex(:,1) = guess;
vals = zeros(nDimP1,2);
vals(1,2) = fun(guess);
vals(1,1) = 1;
for i = 2:nDimP1 
    initialSimplex(:,i) = initialSimplex(:,i-1) + lambda .* unitVector(:,i-1);
end

% sort
iter = 0 ;
vals = evaluateFunctionVertices(initialSimplex, fun);
stop = zeros(nDimP1,1);
if dispOn == 1
    fprintf('Iterations \t')
    fprintf('FunctionValue\n')
end
while iter < maxIter
    iter = iter + 1;
    for i = 1:nDimP1
        vals(i,2) = fun(initialSimplex(:,vals(i,1)));
    end
    % Step 1: Sort the function values
    vals = sortPair(vals,2);
    fBest = vals(1,2);
    fSecondWorst = vals(nDimP1-1,2);
    fWorst = vals(nDimP1, 2);
    centroid = computeCentroid(initialSimplex, vals(:,1));
    % Step 2: Compute the reflection point
    reflectionPoint = centroid + ...
        alpha.*(centroid - initialSimplex(:,vals(nDimP1,1)));
    fReflection = fun(reflectionPoint);
    % Either reflection point is less than the second worst
    % Or its greater than or equal to it
    % Reflect or expand
    if dispOn == 1
        fprintf('%i\t\t', iter)
        fprintf('%f\t', vals(1,2))
    end
    if fReflection < fSecondWorst 
        if fReflection >= fBest
            if dispOn == 1
                fprintf('Reflection\n')
            end
            initialSimplex(:, vals(nDimP1,1)) = reflectionPoint;
        elseif fReflection < fBest
            if dispOn == 1
                fprintf('Expansion\n')
            end
            expansionPoint = centroid + beta.*(reflectionPoint - centroid);
            fExpansion = fun(expansionPoint);
                if fExpansion < fReflection
                    initialSimplex(:, vals(nDimP1,1)) = expansionPoint;
                else
                    initialSimplex(:, vals(nDimP1,1)) = reflectionPoint;
                end
        end
    % Contract or shrink
    elseif fReflection < fWorst
        if fReflection >= fSecondWorst
            outsideContractionPoint = centroid + ...
                gamma.*(reflectionPoint - centroid);
            fOutsideContraction = fun(outsideContractionPoint);
            if fOutsideContraction <= fReflection
                if dispOn == 1
                    fprintf('Outside contraction\n')
                end
                initialSimplex(:, vals(nDimP1,1)) = outsideContractionPoint;
            else
                if dispOn == 1
                    fprintf('Shrink\n')
                end
                initialSimplex = shrinkSimplex(initialSimplex, vals(:,1), delta);
            end
        end
    else
        insideContractionPoint = centroid - gamma.*(reflectionPoint - centroid);
        fInsideContractionPoint = fun(insideContractionPoint);
        if fInsideContractionPoint < fWorst
            if dispOn == 1
                fprintf('Inside contraction\n')
            end
            initialSimplex(:, vals(nDimP1,1)) = insideContractionPoint;
        else
            if dispOn == 1
                fprintf('Shrink\n')
            end
            initialSimplex = shrinkSimplex(initialSimplex, vals(:,1), delta);
        end
    end
    % Stopping rule
    for i = 1:nDimP1
        stop(i) = fun(initialSimplex(:,i));
    end
    if std(stop) < fTol
        minVal = vals(1,2);
        minX = initialSimplex(:,vals(1,1));
        break
    end
    if iter == maxIter
        disp('Max iterations reached, using last value computed.')
        minVal= vals(1,2);
        minX = initialSimplex(:,vals(1,1));
        break
    end
end



