function [obsupdate, backupMeanAndHessian, f] = ...
    ...
    AmarginalF(InfoCell, Factor, yt,...
    currobsmod,  stateTransitions, obsPrecision,...
    backupMeanAndHessian, FactorType, varargin)


options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
    'Display', 'off', 'FiniteDifferenceType', 'forward',...
    'MaxIterations', 100, 'MaxFunctionEvaluations', 5000,...
    'OptimalityTolerance', 1e-8, 'FunctionTolerance', 1e-8, 'StepTolerance', 1e-8);



[K,T] = size(yt);
InfoMat = InfoCell{1,1};
SeriesPerCountry = InfoCell{1,3};
Countries = size(InfoMat,1);
obsupdate = zeros(K,1);
if InfoMat(1) ~= 1
    error('InfoMat(1) is not equal to 1. First Region must start with 1')
end
if FactorType == 1
    fprintf('WORLD ')
    nBlocks = varargin{1};
    sizeBlock = K/nBlocks;
    if floor(sizeBlock) ~= K/nBlocks
        error('Number of blocks invalid for size of system. K/nBlocks not integer')
    end
    t = 1:sizeBlock;
    if size(Factor,1) > 1
        error('Wrong input in AmarginalF')
    end
    factorPrecision = kowStatePrecision(stateTransitions, 1, T  );
    for c = 1:nBlocks
        if c == 1
            RestrictionLevel = 1;
        else
            RestrictionLevel = 0;
        end
        lastMean = backupMeanAndHessian{c,1};
        lastHessian = backupMeanAndHessian{c,2};
        subsetSelect = t + sizeBlock*(c-1);
        yslice = yt(subsetSelect,:);
        precisionSlice = obsPrecision(subsetSelect);
        x0 = currobsmod(subsetSelect);
        [xt, backup, lastHessian] = optimizeA(x0, yslice,...
            precisionSlice,  Factor, factorPrecision, RestrictionLevel,  lastMean, lastHessian, options);
        backupMeanAndHessian{c,1} =  backup;
        backupMeanAndHessian{c,2} = lastHessian;
        obsupdate(subsetSelect) = xt;
    end
    
    f = kowUpdateLatent(yt(:),obsupdate, factorPrecision, obsPrecision);
elseif FactorType ==2
    fprintf('REGION ')
    RegionInfo = InfoCell{1,2};
    Regions = length(unique(InfoMat));
    RestrictionLevel = 1;
    f = zeros(Regions,T);
    %         detectChange = InfoMat(1);
    %         factorPrecision = kowStatePrecision(stateTransitions(detectChange), 1, T  );
    %         F = Factor(detectChange, :);
    %         for c = 1:Countries
    %             lastMean = backupMeanAndHessian{c,1};
    %             lastHessian = backupMeanAndHessian{c,2};
    %             subsetSelect = t + SeriesPerCountry*(c-1);
    %             yslice = yt(subsetSelect,:);
    %             precisionSlice = obsPrecision(subsetSelect);
    %             x0 = currobsmod(subsetSelect);
    %             if InfoMat(c) ~=detectChange
    %                 detectChange =InfoMat(c);
    %                 RestrictionLevel = 1;
    %                 factorPrecision = kowStatePrecision(stateTransitions(detectChange), 1, T  );
    %                 F = Factor(detectChange,:);
    %             else
    %                 RestrictionLevel = 0;
    %             end
    %             [xt, backup, lastHessian] = optimizeA(x0, yslice,...
    %                 precisionSlice,  F, factorPrecision, RestrictionLevel,  lastMean, lastHessian, options);
    %             backupMeanAndHessian{c,1} =  backup;
    %             backupMeanAndHessian{c,2} = lastHessian;
    %             obsupdate(subsetSelect) = xt;
    %         end
    
    for r = 1:Regions
        lastMean = backupMeanAndHessian{r,1};
        lastHessian = backupMeanAndHessian{r,2};
        subsetSelect = RegionInfo(r,1):RegionInfo(r,2);
        yslice = yt(subsetSelect,:);
        precisionSlice = obsPrecision(subsetSelect);
        x0 = currobsmod(subsetSelect);
        factorPrecision = kowStatePrecision(stateTransitions(r), 1, T);
        
        [xt, backup, lastHessian] = optimizeA(x0, yslice,...
            precisionSlice,  Factor(r,:), factorPrecision, RestrictionLevel,  lastMean, lastHessian, options);
        backupMeanAndHessian{r,1} =  backup;
        backupMeanAndHessian{r,2} = lastHessian;
        obsupdate(subsetSelect) = xt;
        f(r,:) =  kowUpdateLatent(yslice(:),  obsupdate(subsetSelect), factorPrecision, precisionSlice);
    end
    
elseif FactorType == 3
    fprintf('COUNTRY ')
    t = 1:SeriesPerCountry;
    RestrictionLevel= 1;
    f = zeros(Countries,T);
    for c= 1:Countries
        lastMean = backupMeanAndHessian{c,1};
        lastHessian = backupMeanAndHessian{c,2};
        subsetSelect = t + SeriesPerCountry*(c-1);
        yslice = yt(subsetSelect,:);
        precisionSlice = obsPrecision(subsetSelect);
        x0 = currobsmod(subsetSelect);
        factorPrecision = kowStatePrecision(stateTransitions(c), 1, T  );
        [xt, lastMean, lastHessian] = optimizeA(x0, yslice,...
            precisionSlice,  Factor(c,:), factorPrecision, RestrictionLevel,  lastMean, lastHessian, options);
        backupMeanAndHessian{c,1} =  lastMean;
        backupMeanAndHessian{c,2} = lastHessian;
        obsupdate(subsetSelect) = xt;
        f(c,:) =  kowUpdateLatent(yslice(:),  obsupdate(subsetSelect), factorPrecision, precisionSlice);
        
    end
else
    error('Incorrect factor type, must be world, region or country (1,2,3)')
end

end

