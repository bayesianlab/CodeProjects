function [sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel, storeStateTransitions, storeFt ] =...
    kowDynFac(yt, Xt, RegionIndices, CountriesThatStartRegions, Countries,...
    SeriesPerCountry, initobsmodel, initgamma, blocks, Sims, burnin )
% sumResiduals2 are not averaged, should they be?
[nEqns, T] = size(yt);
[~, betaDim] = size(Xt);
v0 = 5;
r0 = 10;
lags = 1;
EqnsPerBlock = nEqns/blocks;
Regions = size(RegionIndices,1);
RegionIndicesInFt = 1 + (1:Regions);
CountryIndicesInFt = 1 + Regions + (1:Countries);
nFactors = 1 + Regions + Countries;
[IRegion, ICountry] = kowMakeObsModelIdentityMatrices(nEqns, RegionIndices,...
    SeriesPerCountry, Countries);
zeroOutWorld = zeros(nEqns, 1);
zeroOutRegion = zeros(size(IRegion));
zeroOutCountry = zeros(size(ICountry));
CountryPriorPrecision = 1e-2.*eye(SeriesPerCountry);
CountryPriorlogdet = SeriesPerCountry*log(1e-2);
WorldObsModelPriorPrecision = 1e-2.*eye(EqnsPerBlock);
WorldObsModelPriorlogdet = EqnsPerBlock*log(1e-2);

lastMeanCountry = zeros(SeriesPerCountry, Countries);
lastHessianCountry = reshape(repmat(eye(SeriesPerCountry), 1, Countries), ...
    SeriesPerCountry, SeriesPerCountry, Countries);
lastMeanRegion = zeros(SeriesPerCountry, Countries);
lastHessianRegion = reshape(repmat(eye(SeriesPerCountry), 1, Countries),...
    SeriesPerCountry, SeriesPerCountry, Countries);
lastMeanWorld = zeros(EqnsPerBlock, blocks);
lastHessianWorld = reshape(repmat(eye(EqnsPerBlock),1,blocks), EqnsPerBlock,...
    EqnsPerBlock, blocks);
obsVariance = ones(nEqns,1);
obsPrecision = 1./obsVariance;

currobsmod= initobsmodel;
StateObsModel = [currobsmod(:,1), IRegion.*currobsmod(:,2),...
    ICountry.*currobsmod(:,3)];
stateTransitions = initgamma.*ones(nFactors,1);
Si = kowStatePrecision(stateTransitions, 1, T);

vecF = kowUpdateLatent(yt(:), StateObsModel, Si, obsVariance) ;
Ft = reshape(vecF, nFactors,T);
sumFt = zeros(nFactors, T);
sumFt2 = sumFt;
sumResiduals2 = zeros(nEqns,1);
storeFt = zeros(nFactors,T, Sims-burnin);
storeBeta = zeros(betaDim, Sims -burnin);
storeObsVariance = zeros(nEqns,Sims -burnin);
storeObsModel = zeros(nEqns, 3, Sims-burnin);
storeStateTransitions = zeros(nFactors, lags, Sims-burnin);
sumLastHessianCountry = reshape(repmat(eye(SeriesPerCountry), 1, Countries), ...
    SeriesPerCountry, SeriesPerCountry, Countries);
sumLastHessionRegion = reshape(repmat(eye(SeriesPerCountry), 1, Countries),...
    SeriesPerCountry, SeriesPerCountry, Countries);
sumLastHessianWorld = reshape(repmat(eye(EqnsPerBlock),1,blocks), EqnsPerBlock,...
    EqnsPerBlock, blocks);
sumLastMeanCountry = zeros(SeriesPerCountry, Countries);
sumLastMeanRegion = zeros(SeriesPerCountry, Countries);
sumLastMeanWorld = zeros(EqnsPerBlock, blocks);
for i = 1 : Sims
    fprintf('\n\n  Iteration %i\n', i)
    %% Update mean function
    [beta, ydemut] = kowBetaUpdate(yt(:), Xt, obsPrecision,...
        StateObsModel, Si,  T);
    
    %% Update Obs model 
    % WORLD: Zero out the world to demean y conditional on country, region
    tempStateObsModel = [zeroOutWorld, IRegion .* currobsmod(:,2),...
        ICountry.* currobsmod(:,3)];
    tempydemut = ydemut - tempStateObsModel*Ft; 
    [update,lastMeanWorld, lastHessianWorld, f] = kowWorldBlocks(tempydemut, obsPrecision, currobsmod(:,1),...
        stateTransitions(1), blocks, lastMeanWorld, lastHessianWorld,...
        WorldObsModelPriorPrecision, WorldObsModelPriorlogdet);
    currobsmod(:,1) = update;
    Ft(1,:) = f;
   
    % REGION: Zero out the region to demean y conditional on the world,country 
    tempStateObsModel = [currobsmod(:,1),...
        zeroOutRegion, ICountry.* currobsmod(:,3)];
    tempydemut = ydemut - tempStateObsModel*Ft; 

    [update, lastMeanRegion, lastHessianRegion, f] =  ...
            kowRegionBlocks(tempydemut,obsPrecision,currobsmod(:,2),...
            stateTransitions(1+(1:Regions)), CountriesThatStartRegions,...
            SeriesPerCountry,Countries, lastMeanRegion,lastHessianRegion,...
            CountryPriorPrecision, CountryPriorlogdet);
    currobsmod(:,2) = update;
    Ft(RegionIndicesInFt,:) = f;
    
    % COUNTRY: Zero out the world to demean y conditional on world, region
    tempStateObsModel = [currobsmod(:,1), IRegion .* currobsmod(:,2),...
        zeroOutCountry ];
    tempydemut = ydemut - tempStateObsModel*Ft;
    [update, lastMeanRegion, lastHessianRegion, f] = ...
        kowCountryBlocks(tempydemut, obsPrecision, currobsmod(:,3),...
            stateTransitions(CountryIndicesInFt),SeriesPerCountry, Countries,...
            lastMeanCountry, lastHessianCountry, CountryPriorPrecision, CountryPriorlogdet);
   currobsmod(:,3) = update;
   Ft(CountryIndicesInFt, :) = f;
    
    StateObsModel = [currobsmod(:,1), IRegion .* currobsmod(:,2),...
        ICountry.* currobsmod(:,3)];

    %% Update Obs Equation Variances
    residuals = ydemut - StateObsModel*Ft;
    [obsVariance,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
    obsPrecision = 1./obsVariance;
    
    %% Update State Transition Parameters
    [WorldAr] = kowUpdateArParameters(stateTransitions(1), Ft(1,:), 1);
    [RegionAr] = kowUpdateArParameters(stateTransitions(RegionIndicesInFt),...
        Ft(RegionIndicesInFt,:), 1);
    [CountryAr] = kowUpdateArParameters(stateTransitions(CountryIndicesInFt),...
        Ft(CountryIndicesInFt,:), 1);
    stateTransitions = [WorldAr;RegionAr;CountryAr];
    
    %% Update the State Variance Matrix
    Si = kowStatePrecision(stateTransitions, 1, T);

    %% Store means and second moments
    if i > burnin
        v = i -burnin;
        storeFt(:,:,v) = Ft;
        storeBeta(:,v) = beta;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
        storeObsVariance(:,v) = obsVariance;
        storeObsModel(:,:,v) = currobsmod;
        storeStateTransitions(:,:,v) = stateTransitions;
        sumResiduals2 = sumResiduals2 + r2;
        sumLastHessianCountry = sumLastHessianCountry + lastHessianCountry;
        sumLastHessionRegion = sumLastHessionRegion + lastHessianRegion;
        sumLastHessianWorld = sumLastHessianWorld + lastHessianWorld;
        sumLastMeanCountry = sumLastMeanCountry + lastMeanCountry;
        sumLastMeanRegion = sumLastMeanRegion + lastMeanRegion;
        sumLastMeanWorld = sumLastMeanWorld + lastMeanWorld;
    end
end
Runs = Sims- burnin;
sumFt = sumFt./Runs;
sumFt2 = sumFt2./Runs;
end

