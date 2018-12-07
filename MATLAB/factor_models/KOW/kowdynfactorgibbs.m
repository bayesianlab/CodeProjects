function [sumFt, sumFt2, storeFt, storeBeta, storeObsModel, storeObsVariance]...
    = kowdynfactorgibbs(ys, SurX, v0, r0,...
    Sims, burnin )
%% TODO 
% Does the gamma distribution need the beta parameter to be inverted?
% What about the log of the alphas?
% need to save the parameters for inverse 
% gamma distribution for obsEqnVariances


%% Initializations 
% Maximization parameters for loadings mean and variance step. 

Countries=60;
Regions = 7;
SeriesPerCountry=3;
nFactors = Countries + Regions + 1;
Arp= 3;
[Eqns,T] = size(ys);
blocks = 36;
eqnspblock = Eqns/blocks;
betaDim = size(SurX,2);
regionIndices = [1,4,6,24,42,49,55, -1];
regioneqns = [1,9;10,15;16,69;70,123;124,144;145,162;163,180];
[IOregion,IOcountry] = kowMakeObsModelIdentityMatrices(Eqns,...
    regioneqns, SeriesPerCountry, Regions,Countries);
zeroOutRegion = zeros(size(IOregion));
zeroOutCountry = zeros(size(IOcountry));
zeroOutWorld = zeros(Eqns, 1);
countriesInFt = 9:68;
regionsInFt = 2:8;
oldHessianCountry = reshape(repmat(eye(SeriesPerCountry), 1, Countries), ...
    SeriesPerCountry, SeriesPerCountry, Countries);
oldHessianRegion = reshape(repmat(eye(SeriesPerCountry), 1, Countries),...
    SeriesPerCountry, SeriesPerCountry, Countries);
oldHessianWorld = reshape(repmat(eye(eqnspblock),1,blocks), eqnspblock,...
    eqnspblock, blocks);
oldMeanCountry = zeros(SeriesPerCountry, Countries);
oldMeanRegion = zeros(SeriesPerCountry, Countries);
oldMeanWorld = zeros(eqnspblock, blocks);
% Precalculated priors for country and world
CountryObsModelPriorPrecision = 1e-2.*eye(SeriesPerCountry);
CountryObsModelPriorlogdet = SeriesPerCountry*log(1e-2);
WorldObsModelPriorPrecision = 1e-2.*eye(eqnspblock);
WorldObsModelPriorlogdet = eqnspblock*log(1e-2);
% Initialize values for parameters 
currobsmod = zeros(Eqns, 3);
obsEqnVariances = ones(Eqns,1);
obsEqnPrecision = 1./obsEqnVariances;
RegionAr= zeros(Regions,Arp) ;
CountryAr = zeros(Countries,Arp);
WorldAr = zeros( 1,Arp);
stacktrans = [WorldAr;RegionAr;CountryAr];
% Matrix form of the Observation model. Multiplies all the 
% state variables in one step. 
StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
    IOcountry .* currobsmod(:,3)];
% The covariance matrix according to Fahrmeir and Kaufman
Si = kowMakeVariance(stacktrans,1, T);
% Vectorized state variable initialization and reshaped version
% for fast matrix multiplication.
vecF = kowUpdateLatent(ys(:), StateObsModel, Si, obsEqnVariances) ;
Ft = reshape(vecF, nFactors,T);

%% Storage contaianers for averages of posteriors
sumFt = zeros(nFactors, T);
sumFt2 = sumFt;
storeFt = zeros(nFactors,T, Sims-burnin);
storeBeta = zeros(betaDim, Sims -burnin);
storeObsVariance = zeros(Eqns,Sims -burnin);
storeObsModel = zeros(Eqns, Arp, Sims-burnin);
storeStateTransitions = zeros(nFacotrs, Arp, Sims-burnin);
sumResiduals2 = zeros(Eqns*T,1);
alphaStarNum = zeros(nFactors, Sims-burnin);
%% MCMC of Algorithm 3 Chan&Jeliazkov 2009
tic
for i = 1 : Sims
    fprintf('\n\n  Iteration %i\n', i)
    %% Update mean function
    [beta, ydemut] = kowupdateBetaPriors(ys(:), SurX, obsEqnPrecision,...
        StateObsModel, Si,  T);
    
    %% Update Obs model 
    % WORLD: Zero out the world to demean y conditional on country, region
    tempStateObsModel = [zeroOutWorld, IOregion .* currobsmod(:,2),...
        IOcountry.* currobsmod(:,3)];
    tempydemut = ydemut - tempStateObsModel*Ft;  
    [worldob, Sworld, oldMeanWorld, oldHessianWorld] = ...
        kowUpdateWorldObsModel(tempydemut, obsEqnPrecision,currobsmod(:,1),...
            WorldAr, WorldObsModelPriorPrecision,...
            WorldObsModelPriorlogdet, blocks,Eqns, oldMeanWorld,...
            oldHessianWorld, i);
    currobsmod(:,1) = worldob;
    Ft(1,:) = kowUpdateLatent(tempydemut(:),currobsmod(:,1), Sworld,...
        obsEqnPrecision)';
    
    % REGION: Zero out the region to demean y conditional on the world,country 
    tempStateObsModel = [currobsmod(:,1),...
        zeroOutRegion, IOcountry.* currobsmod(:,3)];
    tempydemut = ydemut - tempStateObsModel*Ft;         
    [currobsmod(:,2),oldMeanRegion, oldHessianRegion] = ...
        kowUpdateRegionObsModel(tempydemut, obsEqnPrecision,currobsmod(:,2),...
            CountryAr,Countries, SeriesPerCountry, CountryObsModelPriorPrecision,...
            CountryObsModelPriorlogdet, regionIndices, oldMeanRegion,...
            oldHessianRegion, i);    
    Ft(regionsInFt, :) = kowUpdateRegionFactor(tempydemut,...
        obsEqnPrecision, currobsmod(:,2),RegionAr, regioneqns, T);
    
    % COUNTRY: Zero out the world to demean y conditional on world, region
    tempStateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
        zeroOutCountry ];
    tempydemut = ydemut - tempStateObsModel*Ft;
    [currobsmod(:,3), oldMeanCountry, oldHessianCountry] = ...
        kowUpdateCountryObsModel(tempydemut, obsEqnPrecision,currobsmod(:,3), ...
            CountryAr,Countries, SeriesPerCountry, CountryObsModelPriorPrecision,...
            CountryObsModelPriorlogdet,  oldMeanCountry, oldHessianCountry, i);
    Ft(countriesInFt, :) = kowUpdateCountryFactor(tempydemut,...
        obsEqnPrecision, currobsmod(:,3),...
             CountryAr, Countries, SeriesPerCountry, T);
    
    StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
        IOcountry.* currobsmod(:,3)];

    %% Update Obs Equation Variances
    residuals = ydemut - StateObsModel*Ft;
    [obsEqnVariances,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
    obsEqnPrecision = 1./obsEqnVariances;
    
    %% Update State Transition Parameters
    [WorldAr, wml] = kowUpdateArParameters(WorldAr, Ft(1,:), Arp);
    [RegionAr, rml] = kowUpdateArParameters(RegionAr, Ft(regionsInFt,:), Arp);
    [CountryAr, cml] = kowUpdateArParameters(CountryAr, Ft(countriesInFt,:), Arp);
    stacktrans = [WorldAr;RegionAr;CountryAr];
    
    %% Update the State Variance Matrix
    Si = kowMakeVariance(stacktrans, 1, T);
    
    %% Store means and second moments
    if i > burnin
        v = i -burnin;
        storeFt(:,:,v) = Ft;
        storeBeta(:,v) = beta;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
        storeObsVariance(:,v) = obsEqnVariances;
        storeObsModel(:,:,v) = currobsmod;
        storeStateTransitions(:,:,v) = stacktrans;
        alphaStarNum(:,v) = [wml;rml;cml];
        sumResiduals2 = sumResiduals2 + r2;
        % Save a temporary object every 500 iterations after the burnrin
%         if mod(v,500) == 0
%             tempfilename = createDateString('tempFtupdate');
%             tempfilename2 = createDateString('tempFt2update');
%             tempitem = sumFt./(v);
%             tempitem2 = sumFt2./(v);
%             save(tempfilename, 'tempitem');
%             save(tempfilename2, 'tempitem2');
%         end
    end
end
Runs = Sims-burnin;
sumFt =  sumFt./Runs;
sumFt2 = sumFt2./Runs;
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start Reduced Runs 
RR = 1;
SubRuns = 100;
ArStar = mean(storeStateTransitions,3);
WorldAr = ArStar(1,:);
RegionAr = ArStar(regionsInFt, :);
CountryAr = ArStar(countriesInFt, :);
omegaGammaParameter = sumResiduals2./Runs;
omegaStar = mean(storeObsVariance,2);
obsPrecisionStar = 1./omegaStar;
Sstar = kowMakeVariance(ArStar, 1, T);
alphaStarDenom = zeros(nFactors, SubRuns);
storeRRbeta = zeros(betaDim, SubRuns);
sumFtRR = zeros(nFactors,T);
for r = 1:RR
    if r == 1
        for n = 1:SubRuns
            % Reduced run 1, marginal gammastar and omega2 star
            %% Update mean function
            [beta, ydemut] = kowupdateBetaPriors(ys(:), SurX, obsPrecisionStar,...
                StateObsModel, Sstar,  T);

            %% Update Obs model 
            % WORLD: Zero out the world to demean y conditional on country, region
            tempStateObsModel = [zeroOutWorld, IOregion .* currobsmod(:,2),...
                IOcountry.* currobsmod(:,3)];
            tempydemut = ydemut - tempStateObsModel*Ft;  
            [worldob, Sworld, oldMeanWorld, oldHessianWorld] = ...
                kowUpdateWorldObsModel(tempydemut, obsPrecisionStar,currobsmod(:,1),...
                    WorldAr, WorldObsModelPriorPrecision,...
                    WorldObsModelPriorlogdet, blocks,Eqns, oldMeanWorld,...
                    oldHessianWorld, i);
            currobsmod(:,1) = worldob;
            Ft(1,:) = kowUpdateLatent(tempydemut(:),currobsmod(:,1), Sworld,...
                obsPrecisionStar)';

            % REGION: Zero out the region to demean y conditional on the world,country 
            tempStateObsModel = [currobsmod(:,1),...
                zeroOutRegion, IOcountry.* currobsmod(:,3)];
            tempydemut = ydemut - tempStateObsModel*Ft;         
            [currobsmod(:,2),oldMeanRegion, oldHessianRegion] = ...
                kowUpdateRegionObsModel(tempydemut, obsPrecisionStar,currobsmod(:,2),...
                    CountryAr,Countries, SeriesPerCountry, CountryObsModelPriorPrecision,...
                    CountryObsModelPriorlogdet, regionIndices, oldMeanRegion,...
                    oldHessianRegion, i);    
            Ft(regionsInFt, :) = kowUpdateRegionFactor(tempydemut,...
                obsPrecisionStar, currobsmod(:,2),RegionAr, regioneqns, T);

            % COUNTRY: Zero out the world to demean y conditional on world, region
            tempStateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
                zeroOutCountry ];
            tempydemut = ydemut - tempStateObsModel*Ft;
            [currobsmod(:,3), oldMeanCountry, oldHessianCountry] = ...
                kowUpdateCountryObsModel(tempydemut, obsPrecisionStar,currobsmod(:,3), ...
                    CountryAr,Countries, SeriesPerCountry, CountryObsModelPriorPrecision,...
                    CountryObsModelPriorlogdet,  oldMeanCountry, oldHessianCountry, i);
            Ft(countriesInFt, :) = kowUpdateCountryFactor(tempydemut,...
                obsPrecisionStar, currobsmod(:,3),...
                     CountryAr, Countries, SeriesPerCountry, T);

            StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
                IOcountry.* currobsmod(:,3)];

            %% Ordinate Estimation For Ar Terms, Get Den for 
            % CJ 2001
            alphaStarDenom(:,s) = kowArMlDenominator(ArStar, Ft);
            storeRRbeta(:,s) = beta;
        end
    elseif r==2
        for n = 1:SubRuns
            
            %% Update Obs model 
            % WORLD: Zero out the world to demean y conditional on country, region
            tempStateObsModel = [zeroOutWorld, IOregion .* currobsmod(:,2),...
                IOcountry.* currobsmod(:,3)];
            tempydemut = ydemut - tempStateObsModel*Ft;  
            [worldob, Sworld, oldMeanWorld, oldHessianWorld] = ...
                kowUpdateWorldObsModel(tempydemut, obsPrecisionStar,currobsmod(:,1),...
                    WorldAr, WorldObsModelPriorPrecision,...
                    WorldObsModelPriorlogdet, blocks,Eqns, oldMeanWorld,...
                    oldHessianWorld, i);
            currobsmod(:,1) = worldob;
            Ft(1,:) = kowUpdateLatent(tempydemut(:),currobsmod(:,1), Sworld,...
                obsPrecisionStar)';

            % REGION: Zero out the region to demean y conditional on the world,country 
            tempStateObsModel = [currobsmod(:,1),...
                zeroOutRegion, IOcountry.* currobsmod(:,3)];
            tempydemut = ydemut - tempStateObsModel*Ft;         
            [currobsmod(:,2),oldMeanRegion, oldHessianRegion] = ...
                kowUpdateRegionObsModel(tempydemut, obsPrecisionStar,currobsmod(:,2),...
                    CountryAr,Countries, SeriesPerCountry, CountryObsModelPriorPrecision,...
                    CountryObsModelPriorlogdet, regionIndices, oldMeanRegion,...
                    oldHessianRegion, i);    
            Ft(regionsInFt, :) = kowUpdateRegionFactor(tempydemut,...
                obsPrecisionStar, currobsmod(:,2), RegionAr, regioneqns, T);

            % COUNTRY: Zero out the world to demean y conditional on world, region
            tempStateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
                zeroOutCountry ];
            tempydemut = ydemut - tempStateObsModel*Ft;
            [currobsmod(:,3), oldMeanCountry, oldHessianCountry] = ...
                kowUpdateCountryObsModel(tempydemut, obsPrecisionStar,currobsmod(:,3), ...
                    CountryAr,Countries, SeriesPerCountry, CountryObsModelPriorPrecision,...
                    CountryObsModelPriorlogdet,  oldMeanCountry, oldHessianCountry, i);
            Ft(countriesInFt, :) = kowUpdateCountryFactor(tempydemut,...
                obsPrecisionStar, currobsmod(:,3),...
                     CountryAr, Countries, SeriesPerCountry, T);

            StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
                IOcountry.* currobsmod(:,3)];
            
        end
    else
        Astar = mean(currobsmod,3);
        for n = 1:SubRuns
            Ft(1,:) = kowUpdateLatent(tempydemut(:),Astar(:,1), Sworld,...
                obsPrecisionStar)';
            Ft(regionsInFt, :) = kowUpdateRegionFactor(tempydemut,...
                obsPrecisionStar, Astar(:,2), RegionAr, regioneqns, T);
            Ft(countriesInFt, :) = kowUpdateCountryFactor(tempydemut,...
                obsPrecisionStar, Astar(:,3),...
                     CountryAr, Countries, SeriesPerCountry, T);
            sumFtRR = sumFtRR + Ft;                 
        end
    end
    
end
betaStar = mean(storeRRbeta,3);
Ftstar = sumFtRR./SubRuns;
logAvg(alphaStarNum) - logAvg(alphaStarDen)



end
