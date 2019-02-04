function [currobsmod, backupMeanAndHessian] = AmarginalF(SeriesPerCountry, InfoMat, Factor, yt,...
    currobsmod,  stateTransitions, obsPrecision, IRegion,ICountry, backupMeanAndHessian)
options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
    'Display', 'off', 'FiniteDifferenceType', 'central',...
    'MaxIterations', 100, 'MaxFunctionEvaluations', 600);
[nFactors, T] = size(Factor);

Regions = length(unique(InfoMat(:,1)));
% May have to remove factor from y1
t = 1:SeriesPerCountry;
[K,T] = size(yt);
changeRegion = InfoMat(1,1);
Countries = size(InfoMat,1);

for c = 1:Countries
    backup = backupMeanAndHessian(c,:);
    
    subsetSelect = t + SeriesPerCountry*(c-1);
    subFt = subsetFt(Factor, [InfoMat(c,:), c], Regions);
    subTrans = subsetFt(stateTransitions, [InfoMat(c,:), c], Regions);
    I1 = IRegion(subsetSelect,:);
    I2 = ICountry(subsetSelect,:);
%     subStateObsModel = StateObsModel(subsetSelect,:);
    %     factorPrecision = kowStatePrecision(diag(subTrans), 1, T);
    yslice = yt(subsetSelect,:);
    precisionSlice = obsPrecision(subsetSelect);
    x0 = currobsmod(subsetSelect,:);
    if c == 1
        % Only on first pass through, all three
        % variables restricted
        RestrictionLevel = 3;
        
        
    elseif InfoMat(c,1) ~= changeRegion
        % All new regions are restricted
        RestrictionLevel = 2;
        Level2Dim = 1 + (K-1)*nFactors;
        changeRegion = InfoMat(c,1);
        ObsPriorMean = ones(1, Level2Dim);
        ObsPriorPrecision = eye(Level2Dim).*1e-2;
        %         x0 = freeObsModelElems(currobsmod(subsetSelect,:), RestrictionLevel);
    else
        % Every country is restricted
        RestrictionLevel = 1;
        Level1Dim = nFactors*K - 1;
        ObsPriorMean = ones(1, Level1Dim);
        ObsPriorPrecision = eye(Level1Dim).*1e-2;
    end
    
    
    [xt, backup, lastHessian] = optimizeA(x0, yslice,...
        precisionSlice, subFt, subTrans, backup, ...
        RestrictionLevel, Regions, I1,I2, options);
    backupMeanAndHessian{c,1} =  backup;
    backupMeanAndHessian{c,2} = lastHessian;
    currobsmod(subsetSelect,:) = xt;
end
end

