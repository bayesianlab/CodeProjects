function [sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel,...
    storeStateTransitions, storeFt] = ...
kowMultiLevelFactor(yt, Xt, RegionIndices,...
    CountriesThatStartRegions, Countries, SeriesPerCountry,...
    Sims, burnin, blocks, blocksRegion, blockSize, initBeta, initobsmod, initGamma, v0, r0)

% All Indexing information intialized here
[K,T, betaDim, EqnsPerBlock, RegionIndicesInFt,...
 CountryIndicesInFt, nFactors] = ...
    kowInitializeIndexInfo(yt,Xt,blocks,RegionIndices,Countries);
% All Storage containers made here
[IRegion, ICountry] = kowMakeObsModelIdentityMatrices(K, RegionIndices,...
    SeriesPerCountry, Countries);
[lastMeanWorld,lastHessianWorld, lastMeanRegion, ...
lastHessianRegion, lastMeanCountry, lastHessianCountry] =...
     kowBackupMeansAndHessians(SeriesPerCountry,Countries, EqnsPerBlock,blocks, blockSize, blocksRegion );
 
[sumFt,sumFt2, sumResiduals2, storeFt, storeBeta,...
storeObsVariance, storeObsModel, storeStateTransitions,...
zeroOutWorld , zeroOutRegion, zeroOutCountry, ...
sumLastMeanCountry,  sumLastMeanRegion, sumLastMeanWorld,...
sumLastHessianCountry,sumLastHessianRegion, sumLastHessianWorld] =...
    kowMakeStorageContainers(Sims,burnin,betaDim, K, T,nFactors, SeriesPerCountry,Countries,...
        EqnsPerBlock, blocks,IRegion,ICountry);
% All priors initialized and initial states of variables
[Si, ObsPriorMean, ObsPriorVar, stateTransitions,...
beta, currobsmod, StateObsModel, Ft, obsVariance,obsPrecision] = ...
    kowInitializePriors(K,T,initobsmod,EqnsPerBlock,...
        SeriesPerCountry, initGamma, initBeta, IRegion,ICountry,...
         nFactors,yt);

     sm11 = zeros(K,Sims);
     sm22 = zeros(K,Sims);
for i = 1 : Sims
    fprintf('\n\n  Iteration %i\n', i)
   %% Update mean function
    [beta, ydemut] = kowBetaUpdate(yt(:), Xt, obsPrecision,...
                                  StateObsModel,Si,T);
     
   %% Update Obs model 
      %% REGION: Zero out the region to demean y conditional on the world,country 
    tempStateObsModel = [currobsmod(:,1),...
        zeroOutRegion, ICountry.* currobsmod(:,3)];
    tempydemut = ydemut - tempStateObsModel*Ft;
    sm22(:,i) = mean(tempydemut,2)
     [obsupdate,lastMeanRegion,lastHessianRegion,f  ] = kowRegionBlocks( tempydemut,obsPrecision, currobsmod(:,2),...
        stateTransitions(RegionIndicesInFt), RegionIndices, CountriesThatStartRegions,...
        SeriesPerCountry, Countries, lastMeanRegion, lastHessianRegion,...
        ObsPriorMean,ObsPriorVar, Ft(RegionIndicesInFt,:), i, burnin );
    currobsmod(:,2) = obsupdate;
    Ft(RegionIndicesInFt,:) = f;
      %% WORLD: Zero out the world to demean y conditional on country, region
    tempStateObsModel = [zeroOutWorld, IRegion .* currobsmod(:,2),...
        ICountry.* currobsmod(:,3)];
    tempydemut = ydemut - tempStateObsModel*Ft; 
    sm11(:,i) = mean(tempydemut,2)
    [obsupdate,lastMeanWorld, lastHessianWorld, f] = ...
    kowWorldBlocks(tempydemut, obsPrecision, currobsmod(:,1),...
        stateTransitions(1), blocks, lastMeanWorld, lastHessianWorld,...
        ObsPriorMean,ObsPriorVar, Ft(1,:), i, burnin);
    currobsmod(:,1) = obsupdate;
    Ft(1,:) = f;
    




    

%     %% COUNTRY: Zero out the country to demean y conditional on world, region        
%     tempStateObsModel = [currobsmod(:,1), IRegion .* currobsmod(:,2),...
%         zeroOutCountry ];
%     tempydemut = ydemut - tempStateObsModel*Ft;
%     [obsupdate, lastMeanCountry, lastHessianCountry,f ] =...
%         kowCountryBlocks(tempydemut, obsPrecision, currobsmod(:,3),...
%         stateTransitions(CountryIndicesInFt), SeriesPerCountry,...
%         Countries, lastMeanCountry, lastHessianCountry,...
%         ObsPriorMean,ObsPriorVar,...
%         Ft(CountryIndicesInFt,:), i, burnin);
%     currobsmod(:,3) = obsupdate;
%     Ft(CountryIndicesInFt, :) = f;

    StateObsModel = [currobsmod(:,1), IRegion.*currobsmod(:,2),...
          ICountry.*currobsmod(:,3)];

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
    stateTransitionsAll = stateTransitions.*eye(nFactors);
    Si = kowStatePrecision(stateTransitionsAll, 1, T);
   
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
        sumResiduals2 = sumResiduals2 + r2;
        sumLastHessianCountry = sumLastHessianCountry + lastHessianCountry;
        sumLastHessianRegion = sumLastHessianRegion + lastHessianRegion;
        sumLastHessianWorld = sumLastHessianWorld + lastHessianWorld;
        sumLastMeanCountry = sumLastMeanCountry + lastMeanCountry;
        sumLastMeanRegion = sumLastMeanRegion + lastMeanRegion;
        sumLastMeanWorld = sumLastMeanWorld + lastMeanWorld;

    end
    
end
save('test.mat', 'sm11', 'sm22')
Runs = Sims- burnin;
sumFt = sumFt./Runs;
sumFt2 = sumFt2./Runs;
end

