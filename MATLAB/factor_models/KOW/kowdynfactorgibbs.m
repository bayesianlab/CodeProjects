function [sumFt, sumFt2, ml] = kowdynfactorgibbs(ys, SurX, v0, r0,Sims, burnin, ReducedRuns )
%% TODO 
% Should have available some averaged parameters for the mean and 
% hessian of the observation model parameters. 

% What about the log of the alphas?



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
sumOldHessianCountry = reshape(repmat(eye(SeriesPerCountry), 1, Countries), ...
    SeriesPerCountry, SeriesPerCountry, Countries);
sumOldHessionRegion = reshape(repmat(eye(SeriesPerCountry), 1, Countries),...
    SeriesPerCountry, SeriesPerCountry, Countries);
sumOldHessianWorld = reshape(repmat(eye(eqnspblock),1,blocks), eqnspblock,...
    eqnspblock, blocks);
sumOldMeanCountry = zeros(SeriesPerCountry, Countries);
sumOldMeanRegion = zeros(SeriesPerCountry, Countries);
sumOldMeanWorld = zeros(eqnspblock, blocks);
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
Si = kowMakePrecision(stacktrans,1, T);
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
storeStateTransitions = zeros(nFactors, Arp, Sims-burnin);
sumResiduals2 = zeros(Eqns,1);
alphaStarNum = zeros(nFactors, Sims-burnin);
% MCMC of Algorithm 3 Chan&Jeliazkov 2009
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
    [WorldAr] = kowUpdateArParameters(WorldAr, Ft(1,:), Arp);
    [RegionAr] = kowUpdateArParameters(RegionAr, Ft(regionsInFt,:), Arp);
    [CountryAr] = kowUpdateArParameters(CountryAr, Ft(countriesInFt,:), Arp);
    stacktrans = [WorldAr;RegionAr;CountryAr];
    
    %% Update the State Variance Matrix
    Si = kowMakePrecision(stacktrans, 1, T);

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
        sumResiduals2 = sumResiduals2 + r2;
        sumOldHessianCountry = sumOldHessianCountry + oldHessianCountry;
        sumOldHessionRegion = sumOldHessionRegion + oldHessianRegion;
        sumOldHessianWorld = sumOldHessianWorld + oldHessianWorld;
        sumOldMeanCountry = sumOldMeanCountry + oldMeanCountry;
        sumOldMeanRegion = sumOldMeanRegion + oldMeanRegion;
        sumOldMeanWorld = sumOldMeanWorld + oldMeanWorld;
%         % Save a temporary object every 500 iterations after the burnrin
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
sumOldHessianCountry = sumOldHessianCountry./Runs;
sumOldHessionRegion = sumOldHessionRegion./Runs;
sumOldHessianWorld = sumOldHessianWorld./Runs;
sumOldMeanCountry = sumOldMeanCountry./Runs;
sumOldMeanRegion = sumOldMeanRegion ./ Runs;
sumOldMeanWorld = sumOldMeanWorld ./Runs;
toc
fprintf('\n\nMAIN RUN COMPLETE. SAVING TO DISK.\n\n')
mrfilename = createDateString('mainrun_');
save(mrfilename); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start Reduced Runs 
fprintf('Reduced Run begin\n')
RR = 4;
ArStar = mean(storeStateTransitions,3);
WorldAr = ArStar(1,:);
RegionAr = ArStar(regionsInFt, :);
CountryAr = ArStar(countriesInFt, :);
omegaGammaParameter = sumResiduals2./Runs;
omegaStar = mean(storeObsVariance,2);
obsPrecisionStar = 1./omegaStar;
Sstar = kowMakePrecision(ArStar, 1, T);
storeRRobsModel = zeros(Eqns, Arp, ReducedRuns);
storeRRbeta = zeros(betaDim, ReducedRuns);
sumFtRR = zeros(nFactors*T, 1);
sumbetaVar = zeros(betaDim, betaDim);
clear storeFt storeObsVariance storeBeta storeObsModel
for r = 1:RR
    if r == 1
        for n = 1:ReducedRuns
            fprintf('\n\n Reduced Run Iteration %i\n', n)
            % Reduced run 1, marginal gammastar and omega2 star
            %% Update mean function
            [beta, ydemut, betaVar] = kowupdateBetaPriors(ys(:), SurX, obsPrecisionStar,...
                StateObsModel, Sstar,  T);
            sumbetaVar = sumbetaVar + betaVar;
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
            pistargamma = kowArMl(storeStateTransitions, ArStar, Ft);
            storeRRbeta(:,n) = beta;
        end
        betaStar = mean(storeRRbeta,2);
        sumbetaVar = sumbetaVar./ReducedRuns;
        ydemut = reshape(ys(:) - SurX*betaStar, Eqns, T);
    elseif r==2
        for n = 1:ReducedRuns
            
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
    elseif r ==3
        for n = 1:ReducedRuns
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

            % Store the observation model at the posterior ordinate
            storeRRobsModel(:,:,n) = currobsmod;
            sumOldHessianCountry = sumOldHessianCountry + oldHessianCountry;
            sumOldHessionRegion = sumOldHessianRegion + oldHessianRegion;
            sumOldHessianWorld = sumOldHessianWorld + oldHessianWorld;
            sumOldMeanCountry = sumOldMeanCountry + oldMeanCountry;
            sumOldMeanRegion = sumOldMeanRegion + oldMeanRegion;
            sumOldMeanWorld = sumOldMeanWorld + oldMeanWorld;            
        end
        sumOldHessianCountry = sumOldHessianCountry./ReducedRuns;
        sumOldHessianRegion = sumOldHessianRegion./ReducedRuns;
        sumOldHessianWorld = sumOldHessianWorld./ReducedRuns;
        sumOldMeanCountry = sumOldMeanCountry./ReducedRuns;
        sumOldMeanRegion = sumOldMeanRegion ./ ReducedRuns;
        sumOldMeanWorld = sumOldMeanWorld ./ReducedRuns;
        Astar = mean(storeRRobsModel,3);
        piastarworld = kowObsModelReducedRunWorld(squeeze(storeRRobsModel(:,1,:)),...
            ydemut, obsPrecisionStar, Astar(:,1), sumOldMeanWorld,...
            sumOldHessianWorld, WorldAr, blocks, Eqns,...
            WorldObsModelPriorPrecision , WorldObsModelPriorlogdet);
        piastarregion = kowObsModelReducedRunRegion(squeeze(storeRRobsModel(:,2,:)), ydemut,...
            obsPrecisionStar, Astar(:,2), sumOldMeanRegion,...
            sumOldHessianRegion, RegionAr, Countries, Eqns,...
            CountryObsModelPriorPrecision , CountryObsModelPriorlogdet,...
            regionIndices);
        piastarcountry = kowObsModelReducedRunCountry(squeeze(storeRRobsModel(:,3,:)),...
            ydemut, obsPrecisionStar, Astar(:,3), sumOldMeanCountry,...
            sumOldHessianCountry, CountryAr, Countries,...
            CountryObsModelPriorPrecision , CountryObsModelPriorlogdet);
        
    else
        Si = kowMakePrecision(ArStar,1,T);
        StateObsModel = [Astar(:,1), IOregion .* Astar(:,2),...
            IOcountry .* Astar(:,3)]; 
        for n = 1:ReducedRuns
            [Ftrr, P] = kowUpdateLatent(ydemut(:), StateObsModel, Si,...
                obsPrecisionStar);
            sumFtRR = sumFtRR + Ftrr;                 
        end
    end
    
end

Ftstar = sumFtRR./ReducedRuns;
fygivenFtstar = kowLL(StateObsModel, ydemut(:), Si, obsPrecisionStar) +...
    logmvnpdf(Ftstar', zeros(1,nFactors*T), eye(nFactors*T)*100) -...
    logmvnpdf(Ftstar',Ftstar', P);
priorBetaStar = logmvnpdf(betaStar', zeros(1,betaDim), eye(betaDim)*100);
priorAstar = logmvnpdf(Astar, zeros(size(Astar,1), size(Astar,2)),...
    eye(size(Astar,2)).*100)';
priorOmegaStar = logigampdf(obsPrecisionStar, .5*v0, .5*r0);
priorGammaStar = logmvnpdf(ArStar, zeros(size(ArStar,1), size(ArStar,2)),...
    eye(size(ArStar,2)).*100)';
priorStar = sum([priorBetaStar;priorAstar;priorOmegaStar;priorGammaStar]);
posteriorStar = sum([piastarcountry;piastarworld; piastarregion;pistargamma;...
    logigampdf(omegaStar, (T+v0)/2, 2./(omegaGammaParameter + r0));...
    logmvnpdf(betaStar', betaStar', sumbetaVar)],1);

ml = fygivenFtstar + priorStar - posteriorStar;
end
