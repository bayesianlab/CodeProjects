function [obsupdate, backupMeanAndHessian] = AmarginalF(SeriesPerCountry, InfoMat, Factor, yt,...
    currobsmod,  stateTransitions, obsPrecision, backupMeanAndHessian)
options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
    'Display', 'off', 'FiniteDifferenceType', 'central',...
    'MaxIterations', 100, 'MaxFunctionEvaluations', 600);

% May have to remove factor from y1
t = 1:SeriesPerCountry;
[K,T] = size(yt);

Countries = size(InfoMat,1);

RestrictionLevel= 1;
obsupdate = zeros(K,1);
for c = 1:Countries
    lastMean = backupMeanAndHessian{c,1};
    lastHessian = backupMeanAndHessian{c,2};
    subsetSelect = t + SeriesPerCountry*(c-1);
    yslice = yt(subsetSelect,:);
    precisionSlice = obsPrecision(subsetSelect);
    x0 = currobsmod(subsetSelect);
    
    factorPrecision = kowStatePrecision(stateTransitions(c), 1, T  );

    [xt, backup, lastHessian] = optimizeA(x0, yslice,...
        precisionSlice,  Factor(c,:), factorPrecision, RestrictionLevel,  lastMean, lastHessian, options);
    
    backupMeanAndHessian{c,1} =  backup;
    backupMeanAndHessian{c,2} = lastHessian;
    obsupdate(subsetSelect) = xt;

end

end

