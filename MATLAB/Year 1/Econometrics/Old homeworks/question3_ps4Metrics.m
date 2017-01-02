
% We want to generate a MC sample and keep the results from a 
% distribution that was not a good approximation. Use the Cauchy.
% The individual bootstap t statistics are calculated by using the 
% formula tStar_b = (betaHatStar - betaHat)var(betaHatStar - betaHat).
% betaHatStar is estimated vector of betas in bootstrap. Betahat is 
% the population regression vector of betas. var is the bootstrap 
% matrix of variances and covariances. 

clear 
clc
format shortG

% Defining parameters needed. 
bootstrapRuns = 100;
level = 10;
sampleSize = 100;
betaTrue = [2;4];
mcSims = 5;
tStat = 1.282;
storageCoverageBands = zeros(mcSims, 1);
theoreticals = zeros(mcSims,1);
error = randomBernoullis(sampleSize);

for j = 1:mcSims
    % Define working data set to generate y's
    xData = [ones(sampleSize,1) normrnd(1, 1, sampleSize, 1)];
    error = randomBernoullis(sampleSize);
    generatedYs = dgp(xData, betaTrue, error);
    betaHat = betaOLS(xData, generatedYs);

    % Estimate residuals for this regression, save 
    residuals = generatedYs - xData * betaHat;

    % variance of population betaHat is calculated, corresponds to 
    % element 2,2
    popVariance = betaHatVar(xData, residuals);
    storageForTs = zeros(bootstrapRuns, 1);
    for i = 1:bootstrapRuns
        % Take a sample of residuals.
        residualPerturbed = perturbWild(residuals); 
        % recreate y data using fixed xs (determined outside loop) and 
        % errors
        yStars = xData*betaHat + residualPerturbed;
        % Recalculate beta hat
        tempBetaStar = betaOLS(xData, yStars);
        tempResids = yStars - xData*tempBetaStar;
        % Calculate the statistic t
        storageForTs(i,1) = ...
            calcStatisticT(tempBetaStar, betaHat, tempResids, xData);
    end
    storageCoverageBands(j,1) = ...
        returnCI(storageForTs, sampleSize, level, betaHat,...
        popVariance);
    theoreticals(j,1) = theoreticalCI(betaHat(2,1),...
        sampleSize,popVariance(2,2),tStat);
end
count = 0;
for ci = 1:length(storageCoverageBands)
    if 4 < storageCoverageBands(ci,1)
        count = count + 1;
    end
end
storageCoverageBands
percentBetaTrueCovered = count/length(storageCoverageBands) 
count = 0;
theoreticals
for ci = 1:length(storageCoverageBands)
    if 4 < storageCoverageBands(ci,1)
        count = count + 1;
    end
end
percentCoveredByT = count/length(storageCoverageBands)





