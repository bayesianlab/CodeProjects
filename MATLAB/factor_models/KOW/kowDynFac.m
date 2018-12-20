function [ ] = kowDynFac(yt, Xt, RegionIndices, Countries, SeriesPerCountry, Sims )
[nEqns, T] = size(yt);
[~, betaDim] = size(Xt);
blocks = 3;
EqnsPerBlock = nEqns/blocks;
Regions = size(RegionIndices,1);
nFactors = 1 + Regions + Countries;
[IRegion, ICountry] = kowMakeObsModelIdentityMatrices(nEqns, RegionIndices,...
    SeriesPerCountry, Countries);
zeroOutRegion = zeros(size(IRegion));
zeroOutCountry = zeros(size(ICountry));
zeroOutWorld = zeros(nEqns, 1);
lastMean = zeros(EqnsPerBlock, 1);
lastHessian = eye(EqnsPerBlock);
obsVariance = ones(nEqns,1);
obsPrecision = 1./obsVariance;

currobsmod= [ones(nEqns,1).*.01, ones(nEqns,1).*.01,ones(nEqns,1).*.01];
StateObsModel = [currobsmod(:,1), IRegion.*currobsmod(:,2),...
    ICountry.*currobsmod(:,3)];
stateTransitions = .40.*ones(nFactors,1);
Si = kowStatePrecision(stateTransitions, 1, T);
vecF = kowUpdateLatent(yt(:), StateObsModel, Si, obsVariance) ;
Ft = reshape(vecF, nFactors,T);
sb = zeros(betaDim,1);
for i = 1 : Sims
    fprintf('\n\n  Iteration %i\n', i)
    %% Update mean function
    [beta, ydemut] = kowBetaUpdate(yt(:), Xt, obsPrecision,...
        StateObsModel, Si,  T);
    sb = beta + sb;
    
    %% Update Obs model 
    % WORLD: Zero out the world to demean y conditional on country, region
    tempStateObsModel = [zeroOutWorld, IRegion .* currobsmod(:,2),...
        ICountry.* currobsmod(:,3)];

    tempydemut = ydemut - tempStateObsModel*Ft; 
    
    kowWorldBlocks(tempydemut, obsPrecision, currobsmod(:,1),...
        stateTransitions(1), blocks, lastMean, lastHessian)
    
%     [worldob, Sworld, oldMeanWorld, oldHessianWorld] = ...
%         kowUpdateWorldObsModel(tempydemut, obsEqnPrecision,currobsmod(:,1),...
%             WorldAr, WorldObsModelPriorPrecision,...
%             WorldObsModelPriorlogdet, blocks,Eqns, oldMeanWorld,...
%             oldHessianWorld, i);
%     currobsmod(:,1) = worldob;
%     Ft(1,:) = kowUpdateLatent(tempydemut(:),currobsmod(:,1), Sworld,...
%         obsEqnPrecision)';
    
%     % REGION: Zero out the region to demean y conditional on the world,country 
%     tempStateObsModel = [currobsmod(:,1),...
%         zeroOutRegion, IOcountry.* currobsmod(:,3)];
%     tempydemut = ydemut - tempStateObsModel*Ft;         
%     [currobsmod(:,2),oldMeanRegion, oldHessianRegion] = ...
%         kowUpdateRegionObsModel(tempydemut, obsEqnPrecision,currobsmod(:,2),...
%             CountryAr,Countries, SeriesPerCountry, CountryObsModelPriorPrecision,...
%             CountryObsModelPriorlogdet, regionIndices, oldMeanRegion,...
%             oldHessianRegion, i);    
%     Ft(regionsInFt, :) = kowUpdateRegionFactor(tempydemut,...
%         obsEqnPrecision, currobsmod(:,2),RegionAr, regioneqns, T);
%     
%     % COUNTRY: Zero out the world to demean y conditional on world, region
%     tempStateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
%         zeroOutCountry ];
%     tempydemut = ydemut - tempStateObsModel*Ft;
%     [currobsmod(:,3), oldMeanCountry, oldHessianCountry] = ...
%         kowUpdateCountryObsModel(tempydemut, obsEqnPrecision,currobsmod(:,3), ...
%             CountryAr,Countries, SeriesPerCountry, CountryObsModelPriorPrecision,...
%             CountryObsModelPriorlogdet,  oldMeanCountry, oldHessianCountry, i);
%     Ft(countriesInFt, :) = kowUpdateCountryFactor(tempydemut,...
%         obsEqnPrecision, currobsmod(:,3),...
%              CountryAr, Countries, SeriesPerCountry, T);
%     
%     StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
%         IOcountry.* currobsmod(:,3)];
% 
%     %% Update Obs Equation Variances
%     residuals = ydemut - StateObsModel*Ft;
%     [obsEqnVariances,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
%     obsEqnPrecision = 1./obsEqnVariances;
%     
%     %% Update State Transition Parameters
%     [WorldAr] = kowUpdateArParameters(WorldAr, Ft(1,:), Arp);
%     [RegionAr] = kowUpdateArParameters(RegionAr, Ft(regionsInFt,:), Arp);
%     [CountryAr] = kowUpdateArParameters(CountryAr, Ft(countriesInFt,:), Arp);
%     stacktrans = [WorldAr;RegionAr;CountryAr];
%     
%     %% Update the State Variance Matrix
%     Si = kowMakeVariance(stacktrans, 1, T);
% 
%     %% Store means and second moments
%     if i > burnin
%         v = i -burnin;
%         storeFt(:,:,v) = Ft;
%         storeBeta(:,v) = beta;
%         sumFt = sumFt + Ft;
%         sumFt2 = sumFt2 + Ft.^2;
%         storeObsVariance(:,v) = obsEqnVariances;
%         storeObsModel(:,:,v) = currobsmod;
%         storeStateTransitions(:,:,v) = stacktrans;
%         sumResiduals2 = sumResiduals2 + r2;
%         sumOldHessianCountry = sumOldHessianCountry + oldHessianCountry;
%         sumOldHessionRegion = sumOldHessionRegion + oldHessianRegion;
%         sumOldHessianWorld = sumOldHessianWorld + oldHessianWorld;
%         sumOldMeanCountry = sumOldMeanCountry + oldMeanCountry;
%         sumOldMeanRegion = sumOldMeanRegion + oldMeanRegion;
%         sumOldMeanWorld = sumOldMeanWorld + oldMeanWorld;
% 
%     end

end
reshape(sb./Sims, SeriesPerCountry + 1,nEqns); 
end

