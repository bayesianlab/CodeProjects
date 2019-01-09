function [sumFt, sumFt2, storeBeta, storeObsVariance, storeObsModel, storeStateTransitions, storeFt, ml ] =...
    kowDynFac(yt, Xt, RegionIndices, CountriesThatStartRegions, Countries,...
    SeriesPerCountry, initobsmodel, initgamma, blocks, Sims, burnin, ReducedRuns )
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
sumLastHessianRegion = reshape(repmat(eye(SeriesPerCountry), 1, Countries),...
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
    
    % COUNTRY: Zero out the country to demean y conditional on world, region
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
        sumLastHessianRegion = sumLastHessianRegion + lastHessianRegion;
        sumLastHessianWorld = sumLastHessianWorld + lastHessianWorld;
        sumLastMeanCountry = sumLastMeanCountry + lastMeanCountry;
        sumLastMeanRegion = sumLastMeanRegion + lastMeanRegion;
        sumLastMeanWorld = sumLastMeanWorld + lastMeanWorld;
    end
end
Runs = Sims- burnin;
sumFt = sumFt./Runs;
sumFt2 = sumFt2./Runs;
fprintf('MAIN RUN COMPLETE\n')
sumFtRR = zeros(nFactors*T, 1);
storeRRbeta = zeros(betaDim, ReducedRuns);
storeRRobsModel = zeros(nEqns, 3, ReducedRuns);
gammaStar = mean(storeStateTransitions,3);
omegaGammaParameter = sumResiduals2./Runs;
Sstar = kowStatePrecision(gammaStar, 1, T);
omegaStar = mean(storeObsVariance,2);
obsPrecisionStar = 1./omegaStar;
sumBetaVar = zeros(betaDim,betaDim);
pistargamma = kowArMl(storeStateTransitions, gammaStar, sumFt);
for rr = 1:3
    fprintf('Reduced Run %i\n', rr)
    if rr == 1
        for n = 1:ReducedRuns
            %% Reduced Run 1
            %% Update mean function
            [beta, ydemut, betaVar] = kowBetaUpdate(yt(:), Xt, obsPrecisionStar,...
                StateObsModel, Sstar,  T);
            sumBetaVar = sumBetaVar + betaVar;
            storeRRbeta(:,n) = beta;
            %% Update Obs model 
            % WORLD: Zero out the world to demean y conditional on country, region
            tempStateObsModel = [zeroOutWorld, IRegion .* currobsmod(:,2),...
                ICountry.* currobsmod(:,3)];
            tempydemut = ydemut - tempStateObsModel*Ft; 
            [update,lastMeanWorld, lastHessianWorld, f] = kowWorldBlocks(tempydemut, obsPrecisionStar, currobsmod(:,1),...
                stateTransitions(1), blocks, lastMeanWorld, lastHessianWorld,...
                WorldObsModelPriorPrecision, WorldObsModelPriorlogdet);
            currobsmod(:,1) = update;
            Ft(1,:) = f;

            % REGION: Zero out the region to demean y conditional on the world,country 
            tempStateObsModel = [currobsmod(:,1),...
                zeroOutRegion, ICountry.* currobsmod(:,3)];
            tempydemut = ydemut - tempStateObsModel*Ft; 

            [update, lastMeanRegion, lastHessianRegion, f] =  ...
                    kowRegionBlocks(tempydemut,obsPrecisionStar,currobsmod(:,2),...
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
                kowCountryBlocks(tempydemut, obsPrecisionStar, currobsmod(:,3),...
                    stateTransitions(CountryIndicesInFt),SeriesPerCountry, Countries,...
                    lastMeanCountry, lastHessianCountry, CountryPriorPrecision, CountryPriorlogdet);
           currobsmod(:,3) = update;
           Ft(CountryIndicesInFt, :) = f;

            StateObsModel = [currobsmod(:,1), IRegion .* currobsmod(:,2),...
                ICountry.* currobsmod(:,3)];
        end
        betaStar = mean(storeRRbeta,2);
        sumBetaVar = sumBetaVar./ReducedRuns;
        ydemut = reshape(yt(:) - Xt*betaStar, nEqns, T);
    elseif rr == 2
        for n = 1:ReducedRuns
            %% Update Obs model 
            % WORLD: Zero out the world to demean y conditional on country, region
            tempStateObsModel = [zeroOutWorld, IRegion .* currobsmod(:,2),...
                ICountry.* currobsmod(:,3)];
            tempydemut = ydemut - tempStateObsModel*Ft; 
            [update,lastMeanWorld, lastHessianWorld, f] = kowWorldBlocks(tempydemut, obsPrecisionStar, currobsmod(:,1),...
                stateTransitions(1), blocks, lastMeanWorld, lastHessianWorld,...
                WorldObsModelPriorPrecision, WorldObsModelPriorlogdet);
            currobsmod(:,1) = update;
            Ft(1,:) = f;

            % REGION: Zero out the region to demean y conditional on the world,country 
            tempStateObsModel = [currobsmod(:,1),...
                zeroOutRegion, ICountry.* currobsmod(:,3)];
            tempydemut = ydemut - tempStateObsModel*Ft; 

            [update, lastMeanRegion, lastHessianRegion, f] =  ...
                    kowRegionBlocks(tempydemut,obsPrecisionStar,currobsmod(:,2),...
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
                kowCountryBlocks(tempydemut, obsPrecisionStar, currobsmod(:,3),...
                    stateTransitions(CountryIndicesInFt),SeriesPerCountry, Countries,...
                    lastMeanCountry, lastHessianCountry, CountryPriorPrecision, CountryPriorlogdet);
           currobsmod(:,3) = update;
           Ft(CountryIndicesInFt, :) = f;

            StateObsModel = [currobsmod(:,1), IRegion .* currobsmod(:,2),...
                ICountry.* currobsmod(:,3)];
            storeRRobsModel(:,:,n) = currobsmod;
            sumLastHessianCountry = sumLastHessianCountry + lastHessianCountry;
            sumLastHessianRegion = sumLastHessianRegion + lastHessianRegion; 
            sumLastHessianWorld = sumLastHessianWorld + lastHessianWorld;
            sumLastMeanCountry = sumLastMeanCountry + lastMeanCountry;
            sumLastMeanRegion = sumLastMeanRegion + lastMeanRegion;
            sumLastMeanWorld = sumLastMeanWorld + lastMeanWorld;             
        end
        sumLastHessianCountry = sumLastHessianCountry./ReducedRuns;
        sumLastHessianRegion = sumLastHessianRegion./ReducedRuns;
        sumLastHessianWorld = sumLastHessianWorld./ReducedRuns;
        sumLastMeanCountry = sumLastMeanCountry./ReducedRuns;
        sumLastMeanRegion = sumLastMeanRegion ./ ReducedRuns;
        sumLastMeanWorld = sumLastMeanWorld ./ReducedRuns;
        Astar = mean(storeRRobsModel,3);
        StateObsModelStar = [Astar(:,1), IRegion .* Astar(:,2),...
            ICountry .* Astar(:,3)]; 
    else
        for n = 1:ReducedRuns
            [Ftrr, P] = kowUpdateLatent(ydemut(:), StateObsModelStar, Sstar,...
                obsPrecisionStar);
            sumFtRR = sumFtRR + Ftrr;                 
        end        
    end
end
piastarworld = kowObsModelReducedRunWorld(squeeze(storeRRobsModel(:,1,:)),...
    ydemut, obsPrecisionStar, Astar(:,1), sumLastMeanWorld,...
    sumLastHessianWorld, WorldAr, blocks, nEqns,...
    WorldObsModelPriorPrecision , WorldObsModelPriorlogdet);
piastarregion = kowObsModelReducedRunRegion(squeeze(storeRRobsModel(:,2,:)), ydemut,...
    obsPrecisionStar, Astar(:,2), sumLastMeanRegion,...
    sumLastHessianRegion, RegionAr, Countries, nEqns,...
    CountryPriorPrecision , CountryPriorlogdet,...
    CountriesThatStartRegions);
piastarcountry = kowObsModelReducedRunCountry(squeeze(storeRRobsModel(:,3,:)),...
    ydemut, obsPrecisionStar, Astar(:,3), sumLastMeanCountry,...
    sumLastHessianCountry, CountryAr, Countries,...
    CountryPriorPrecision , CountryPriorlogdet);
Ftstar = sumFtRR./ReducedRuns;
% Integrate out Ft
fyGivenThetaStar = kowLL(StateObsModelStar, ydemut(:), Sstar, obsPrecisionStar) +...
    logmvnpdf(Ftstar', zeros(1,nFactors*T), eye(nFactors*T)*100) -...
    logmvnpdf(Ftstar',Ftstar', P);
priorBetaStar = logmvnpdf(betaStar', zeros(1,betaDim), eye(betaDim)*100);
priorAstar = logmvnpdf(Astar, zeros(size(Astar,1), size(Astar,2)),...
    eye(size(Astar,2)).*100)';
priorOmegaStar = logigampdf(obsPrecisionStar, .5*v0, .5*r0);
priorGammaStar = logmvnpdf(gammaStar, zeros(size(gammaStar,1), size(gammaStar,2)),...
    eye(size(gammaStar,2)).*100)';
priorStar = sum([priorBetaStar;priorAstar;priorOmegaStar;priorGammaStar]);
posteriorStar = sum([pistargamma;...
    logigampdf(omegaStar, (T+v0)/2, 2./(omegaGammaParameter + r0));...
    logmvnpdf(betaStar',betaStar', sumBetaVar);...
    piastarcountry;piastarworld;piastarregion],1);
fyGivenThetaStar
priorStar
posteriorStar
ml = fyGivenThetaStar + priorStar - posteriorStar;
end

