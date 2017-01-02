function [] = bootstrapT( monteCarloSims, boots,sampSize )
% Runs a bootstrap t with binary error. 
clc

% Defining parameters needed. 
bootstrapRuns = boots;
level = 10;
sampleSize = sampSize;
betaTrue = [2;4];
mcSims = monteCarloSims;
storageCoverageBands = zeros(mcSims, 1);
theoreticals = zeros(mcSims,1);
tStat = 1.282;



xData = [ones(sampleSize,1) normrnd(0, .2, sampleSize, 1)];
% error = normrnd(0,2,sampleSize,1);
error = randomBernoullis(sampleSize);
generatedYs = dgp(xData, betaTrue, error);
betaHat = betaOLS(xData, generatedYs);
residuals = generatedYs - xData * betaHat;
popVariance = betaHatVar(xData, residuals)
for j = 1:mcSims
    % Define working data set to generate y's


   
    

    % Estimate residuals for this regression, save 
    

    % variance of population betaHat is calculated, corresponds to 
    % element 2,2
    
    storageForTs = zeros(bootstrapRuns, 1);
    for i = 1:bootstrapRuns
        % Perturb residuals.
        residualPerturbed = perturbWild(residuals);
%         residualPerturbed = datasample(residuals, length(residuals));

        % recreate y data using fixed xs (determined outside loop) and 
        % errors
        yStars = xData*betaHat + residualPerturbed;
        % Recalculate beta hat
        tempBetaStar = betaOLS(xData, yStars);
        % Calculate the statistic t
        storageForTs(i,1) = ...
            calcStatisticT(tempBetaStar, betaHat,...
            residualPerturbed, xData);
    end
    storageCoverageBands(j,1) = ...
        returnCI(storageForTs, sampleSize,bootstrapRuns,...
                    level, betaHat, popVariance);
    theoreticals(j,1) = theoreticalCI(betaHat(2,1),...
        sampleSize,popVariance(2,2),tStat);
%     [betaHat(2,1),storageCoverageBands(j,1)]
end
count = 0;
for ci = 1:length(storageCoverageBands)
    if 4 < storageCoverageBands(ci,1)
        storageCoverageBands(ci,1);
        count = count + 1;
    end
end
storageCoverageBands
percentBetaTrueCovered = count/length(storageCoverageBands) 
count = 0;
theoreticals
for ci = 1:length(storageCoverageBands)
    if 4 < theoreticals(ci,1);
        count = count + 1;
    end
end
percentCoveredByT = count/length(storageCoverageBands)

end

