clc;
clear;
startRow = 1;
endRow = 500;

y = importYs('PS6Y.txt', startRow,endRow);
xMatrix = importXs('PS6X.txt', startRow,endRow);

% Different colors for dots
cols = [unifrnd(0,1,1,3);...
        unifrnd(0,1,1,3);...
        unifrnd(0,1,1,3);
        unifrnd(0,1,1,3)];
 xRun = 1:500;
    
% Estimate by OLS
olsEstimates = betaOLS(xMatrix, y);

% Get Residuals
residuals = getResids(xMatrix, y, olsEstimates);
yHats = xMatrix*olsEstimates;


%% PLOT 1: Do residuals appear homoskedastic?
doResidsAppearHomo(xMatrix, residuals);

% ReRunning the regression with feasible GLS
resSqd = residuals.^2;
residualReg = betaOLS(xMatrix, resSqd);
reEstimate = feasibleGLS(xMatrix, y);
yFGLSFits = xMatrix * reEstimate;

%% PLOT: feasible least squares residuals, did it fix heteroskedasticity?
figure
scatter(xRun, yFGLSFits, [], cols(1,:), 'filled')
title(' Feasible GLS Residual Plot ')

% Concatenate first three vectors:
paramsFKnots = [0,2,5];
xShort = xMatrix(:,1:3);
splineW = splineVect(xMatrix(:,4), paramsFKnots);
queMat = [xShort splineW];
% % Should be 500x18
% size(queMat)

% % % % % % % % % % % % Spline 
% % % % % % % % % % % % Esitmates 

% Rough Spline Estimate
gammas = betaOLS(queMat, y);
betaShorts = betaOLS(xShort, y);
ySplineFits = queMat * gammas;

%% PLOT: Rough Spline fitted
figure
scatter(xMatrix(:,4), ySplineFits)
title(' Rough Spline Fitted Values ')
residsRoughSpline = y - ySplineFits;

%% PLOT: Rough spline residuals.
figure
scatter(1:500, residsRoughSpline, [], cols(2,:), 'filled')
title(' Rough Spline Residual Plot ' )

% % % % % % % % % % % % 
% % % % % % % % % % % % 

% Smooth Spline Estimate
splineWTilda = smoothSpline(xMatrix(:,4), paramsFKnots);
queMatTilda = [xShort splineWTilda];
sizeQueMatTilda = size(queMatTilda);
gammasTilda = betaOLS(queMatTilda, y);
ySplineHatFits = queMatTilda * gammasTilda;

%% PLOT: Smooth spline fitted values
figure
scatter(xMatrix(:,4), ySplineHatFits)
title('Smoothed Spline Fitted Values')

%% PLOT: Smooth Spline Residuals
residsSpline = y - ySplineHatFits;
figure
scatter(xMatrix(:,4), residsSpline, [], cols(3,:), 'filled')
title( ' Smoothed Spline Residual Plot ' )

figure
plot(xMatrix(:,4), ySplineFits)
title( 'Smooth Spline')


figure
plot(xMatrix(:,4), splineWTilda*gammasTilda(4:10,1))
title( 'Rough Spline' )




