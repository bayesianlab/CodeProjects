function [sumFt, sumFt2, sumBeta, sumBeta2, sumObsVariance,...
    sumObsVariance2] = kowdynfactorgibbs(ys, SurX, v0, r0,...
    Sims, burnin )
%% TODO 
% Verify storage works
% Priors for update beta function are not implemented, now is ols.
% Possibly the Sregion and Scountry matrices could be saved 
% from the update obs model step instead of recreated twice in the updating
% of the  latent states. 

%% Initializations 
% Maximization parameters for loadings mean and variance step. 

Countries=60;
Regions = 7;
SeriesPerCountry=3;
nFactors = Countries + Regions + 1;
Arp= 3;
[Eqns,T] = size(ys);
blocks = 60;
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
% Precalculated priors for country and world
CountryObsModelPriorPrecision = 1e-2.*eye(SeriesPerCountry);
CountryObsModelPriorlogdet = SeriesPerCountry*log(1e-2);
WorldObsModelPriorPrecision = 1e-2.*eye(eqnspblock);
WorldObsModelPriorlogdet = eqnspblock*log(1e-2);
% Initialize the observation model
currobsmod = zeros(Eqns, 3);
obsEqnVariances = ones(Eqns,1);
obsEqnPrecision = 1./obsEqnVariances;
% Initialize the AR terms on the State variables
RegionAr= zeros(Regions,Arp) ;
CountryAr = zeros(Countries,Arp);
WorldAr = zeros( 1,Arp);
stacktrans = [WorldAr;RegionAr;CountryAr];
% Matrix form of the Observation model. Multiplies all the 
% state variables in one step. 
StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
    IOcountry .* currobsmod(:,3)];
% The covariance matrix according to Fahrmeir and Kaufman.
Si = kowMakeVariance(stacktrans,1, T);
% Vectorized state variable initialization and reshaped version
% for fast matrix multiplication.
vecF = kowUpdateLatent(ys(:), StateObsModel, Si, obsEqnVariances) ;
% Ft = reshape(vecF, nFactors,T);
Ft = zeros(nFactors,T);
%% Storage contaianers for averages of posteriors
sumFt = zeros(size(Ft,1), size(Ft,2));
sumFt2 = sumFt;
sumBeta = zeros(betaDim, 1);
sumBeta2 = sumBeta;
sumObsVariance = zeros(length(obsEqnVariances),1);
sumObsVariance2 =  sumObsVariance;
%% MCMC of Algorithm 3 Chan&Jeliazkov 2009
storeB = zeros(betaDim, Sims);
storeFt = zeros(size(Ft,1), size(Ft,2), Sims);

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
    [worldob, Sworld] = kowUpdateWorldObsModel(tempydemut,...
        obsEqnPrecision,currobsmod(:,1),...
        WorldAr, WorldObsModelPriorPrecision,...
        WorldObsModelPriorlogdet, blocks,Eqns, T, oldHessianWorld, i);
    currobsmod(:,1) = worldob;
    Ft(1,:) = kowUpdateLatent(tempydemut(:),currobsmod(:,1), Sworld,...
        obsEqnPrecision)';
    
    % COUNTRY: Zero out the world to demean y conditional on world, region
    tempStateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
        zeroOutCountry ];
    tempydemut = ydemut - tempStateObsModel*Ft;
    currobsmod(:,3) = kowUpdateCountryObsModel(tempydemut,...
        obsEqnPrecision,currobsmod(:,3),CountryAr,Countries,...
        SeriesPerCountry,CountryObsModelPriorPrecision,...
        CountryObsModelPriorlogdet, T, oldHessianCountry, i);
    Ft(countriesInFt, :) = kowUpdateCountryFactor(tempydemut,...
        obsEqnPrecision, currobsmod(:,3),...
             CountryAr, Countries, SeriesPerCountry, T);
    
    StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2),...
        IOcountry.* currobsmod(:,3)];

    % REGION: Zero out the region to demean y conditional on the world,country 
    tempStateObsModel = [currobsmod(:,1),...
        zeroOutRegion, IOcountry.* currobsmod(:,3)];
    tempydemut = ydemut - tempStateObsModel*Ft;         
    currobsmod(:,2) = kowUpdateRegionObsModel(tempydemut,...
        obsEqnPrecision,currobsmod(:,2),...
        CountryAr,Countries, SeriesPerCountry,...
        CountryObsModelPriorPrecision, CountryObsModelPriorlogdet,...
        regionIndices, T, oldHessianRegion, i);    
    Ft(regionsInFt, :) = kowUpdateRegionFactor(tempydemut,...
        obsEqnPrecision, currobsmod(:,2),RegionAr, regioneqns, T);

    %% Update Obs Equation Variances
    residuals = ydemut - StateObsModel*Ft;
    obsEqnVariances = kowUpdateObsVariances(residuals, v0,r0,T);
    obsEqnPrecision = 1./obsEqnVariances;
    
    %% Update State Transition Parameters
    WorldAr = kowUpdateArParameters(WorldAr, Ft(1,:), Arp);
    RegionAr = kowUpdateArParameters(RegionAr, Ft(regionsInFt,:), Arp);
    CountryAr = kowUpdateArParameters(CountryAr, Ft(countriesInFt,:), Arp);
    stacktrans = [WorldAr;RegionAr;CountryAr];
    
    %% Update the State Variance Matrix
    Si = kowMakeVariance(stacktrans, 1, T);
    
    %% Store means and second moments
    if i > burnin
        sumBeta = sumBeta + beta;
        sumBeta2 = sumBeta2 + beta.^2;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
        sumObsVariance = sumObsVariance + obsEqnVariances;
        sumObsVariance2 = sumObsVariance2 + obsEqnVariances.^2;
        % Save a temporary object every 100 iterations after the burnrin
        if mod(i,100) == 0
            tempfilename = createDateString('tempFtupdate_at_.mat');
            save(tempfilename, sumFt./i-burnin)
        end

    end
     hold on
    plot(Ft(1,:))
    drawnow
end
Runs = Sims-burnin;
sumFt =  sumFt./Runs;
sumFt2 = sumFt2./Runs;
sumBeta = sumBeta./Runs;
sumBeta2 = sumBeta2./Runs;
sumObsVariance = sumObsVariance./Runs;
sumObsVariance2 = sumObsVariance2./Runs;
toc
end
