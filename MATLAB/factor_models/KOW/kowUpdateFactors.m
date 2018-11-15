function [  ] = kowUpdateFactors(demeanedy, ObsModel, ...
    SparseObservationCovar, TransitionWorld, TransitionRegion,...
    TransitionCountry, regionIndices)
% % demeanedy is y demeaned by mean function. It is expected to be 
% % given as (y1,...,yK)^T and columns are t= 1,...,T, K is the dimension.
% % ObsModel is the Observation Equation transition matrix. Every column
% % is expected to be for one of the factors, rows for equations 1,...,K. 
% % SparseObservationCovar is a sparse matrix with the observation variance
% % on the diagonal. 
% % TransitionWorld is the transition matrix on the AR(3) State equation for
% % the world factor.
% % TransitionRegion is the transition equation for the AR(3) Region factor
% % and rows are expected to correspond to different regions, similarly 
% % defined is the TransitionCountry.
% % regionIndices are the indices corresponding to which equations in 
% % demeanedy correspond to which regions. 
 
T = size(demeanedy,1);
K = size(SparseObservationCovar,1); 
restrictedVariance = 1;
Regions = 7;
Countries = 60;
EqnsPerCountry = 3;
ObsCovDiag = spdiags(SparseObservationCovar,0);
selectCountryEqns = 1:3;
R = [1;0;0];
Arp = length(TransitionWorld);
eyeArp = eye(Arp);
zerosK = zeros(K,1);


P0WorldSave = zeros(Arp, Arp, T);
[P0World, PhiWorld, RRp] = kowKalmanInitRecursion(TransitionWorld, R, restrictedVariance);
Hworld = [ObsModel(:,1), zerosK, zerosK];  
worldFactor0 = zeros(3,1);
WorldUpdates = zeros(Arp,T);
WorldVarPredictSave = zeros(Arp, Arp, T);

P0Regions = zeros(Arp, Arp,Regions);
P0RegionsSave = zeros(Arp,Arp,Regions,T);
PhiRegions = zeros(Arp, Arp, Regions);
for r = 1:Regions
    first=regionIndices(r,1);
    last=regionIndices(r,2);
    zerofill = zeros(length(ObsModel(first:last,2)),1);
    Hregion(r) = {[ObsModel(first:last,2), zerofill, zerofill]};
    [P0Regions(:,:,r, 1), PhiRegions(:,:,r), ~]  = kowKalmanInitRecursion(TransitionRegion(r,:), R, restrictedVariance);
end
RegionPredicts = zeros(Arp,Regions);
RegionPredictsSave = zeros(Arp, Regions, T);
RegionUpdates = zeros(Arp, Regions, T);
RegionVarPredicts = zeros(Arp, Arp, Regions,T);
regionFactor0 = zeros(3,Regions);
muregion = zeros(K,1);

P0Countries = zeros(Arp,Arp, Countries);
P0CountriesSave = zeros(Arp,Arp,Countries,T);
CountryUpdates = zeros(Arp, Countries,T);
PhiCountries = zeros(Arp,Arp,Countries);
Hcountries = zeros(Arp, Arp, Countries);
zerofill = zeros(EqnsPerCountry,1);
for c= 1:Countries
    indices = selectCountryEqns + (c-1)*3;
    Hcountries(:,:,c) = [ObsModel(indices,3), zerofill, zerofill];
    [P0Countries(:,:,c, 1), PhiCountries(:,:,c), ~] = kowKalmanInitRecursion(TransitionCountry(c,:), R, restrictedVariance); 
end
CountryPredicts= zeros(Arp,Countries);
CountryPredictsSave = zeros(Arp, Countries, T);
CountryVarPredicts = zeros(Arp, Arp, Countries, T);
countryFactor0 = zeros(3, Countries);
mucountry = muregion;

for t = 1:T
    %% Prediction 
    WorldPredict = PhiWorld*worldFactor0;
    WorldVarPredict = PhiWorld*P0World*PhiWorld' + RRp;
    WorldVarPredictSave(:,:,t) = WorldVarPredict;
    muworld = Hworld*WorldPredict;
    
    for r = 1:Regions
        first=regionIndices(r,1);
        last=regionIndices(r,2);
        RegionPredicts(:,r) = PhiRegions(:,:,r)*regionFactor0(:,r);
        RegionVarPredicts(:,:,r,t) = PhiRegions(:,:,r) * P0Regions(:,:,r) * PhiRegions(:,:,r)' + RRp;
        muregion(first:last) = Hregion{r}*RegionPredicts(:,r);
    end
    RegionPredictsSave(:,:,t) = RegionPredicts;
    
    for c = 1:Countries
        indices = selectCountryEqns + (c-1)*3;
        CountryPredicts(:,c) = PhiCountries(:,:,c)*countryFactor0(:,c);
        CountryVarPredicts(:, :, c, t) = PhiCountries(:,:,c) * P0Countries(:,:,c) * PhiCountries(:,:,c)' + RRp;
        mucountry(indices) = Hcountries(:,:,c)* CountryPredicts(:,c);
    end
    CountryPredictsSave(:,:,t)= CountryPredicts;
    
    %% Residual Calculation 
    resid = demeanedy(t,:)' - (muworld + muregion + mucountry);
    residvar = Hworld*WorldVarPredict*Hworld' + SparseObservationCovar;
    
    %% Kalman Gain Calculations and Updating
    WorldKalman = WorldVarPredict * Hworld'/residvar;
    worldFactor0 = WorldPredict + WorldKalman*resid;
    tempA =  (eyeArp -  WorldKalman*Hworld);
    P0World =  tempA * WorldVarPredict * tempA' + WorldKalman*SparseObservationCovar * WorldKalman';
    P0WorldSave(:,:,t) = P0World;
    WorldUpdates(:,t) = worldFactor0;

    
    for r = 1:Regions
        first=regionIndices(r,1);
        last=regionIndices(r,2);
        hr = Hregion{r};
        sr = RegionVarPredicts(:,:,r,t);
        tempSigma = diag(ObsCovDiag(first:last));
        residvar =  hr*sr*hr' + tempSigma;
        RegionKalman = sr*hr'/residvar;
        tempA = eyeArp - RegionKalman*hr;
        P0Regions(:,:,r) = tempA*sr*tempA' + RegionKalman*tempSigma*RegionKalman';
        regionFactor0(:,r) = RegionPredicts(:,r) + RegionKalman*resid(first:last);
    end
    RegionUpdates(:,:,t) = regionFactor0; 
    P0RegionsSave(:,:,:,t) = P0Regions;
    
    for c = 1:Countries
        indices = selectCountryEqns + (c-1)*3;
        hc = Hcountries(:,:,c);
        sc = CountryVarPredicts(:,:,c,t);
        tempSigma = diag(ObsCovDiag(indices));
        residvar = hc*sc*hc' + tempSigma;
        CountryKalman = sc*hc'/residvar;
        tempA = eyeArp - CountryKalman*hc;
        countryFactor0(:,c) = CountryPredicts(:,c) + CountryKalman*resid(indices);
        P0Countries(:,:,c) = tempA*sc*tempA' + CountryKalman*tempSigma*CountryKalman';
    end
    CountryUpdates(:,:,t) = countryFactor0;
    P0CountriesSave(:,:,:,t) = P0Countries;
end
%% Kalman Smoothing 
WorldSmoothed = zeros(Arp, T);
WorldSmoothed(:,T) = worldFactor0;
WorldVarianceSmoothed = zeros(Arp, Arp, T);
WorldVarianceSmoothed(:,:,T) = P0WorldSave(:,:,T);
worldfactor = zeros(1,T);
worldfactor(T) = worldFactor0(1);

RegionSmoothed = zeros(Arp, Regions, T);
RegionSmoothed(:,:,T) = regionFactor0;
RegionVarianceSmoothed = zeros(Arp, Arp, Regions, T);
RegionVarianceSmoothed(:,:,:,T) = P0RegionsSave(:,:,:,T);
regionalfactors = zeros(Regions, T);
regionalfactors(:,T) = regionFactor0(1,:)'; 

CountrySmoothed = zeros(Arp, Countries, T);
CountrySmoothed(:,:,T) = countryFactor0;
CountryVarianceSmoothed = zeros(Arp, Arp, Countries, T);
CountryVarianceSmoothed(:,:,:,T) = P0CountriesSave(:,:,:,T);
countryfactors = zeros(Countries, T);
countryfactors(:,T) = countryFactor0(1,:)';
for t=(T-1):(-1):1

    WorldSmoother = P0WorldSave(:,:,t)*PhiWorld'/WorldVarPredictSave(:,:,t+1);
    WorldSmoothed(:,t) = WorldUpdates(:,t) + WorldSmoother*(WorldSmoothed(:, t+1) - PhiWorld*WorldUpdates(:,t));
    WorldVarianceSmoothed(:,:,t) = P0WorldSave(:,:,t) - WorldSmoother*( WorldVarianceSmoothed(:,:,t+1) - WorldVarPredictSave(:,:,t+1))*WorldSmoother';
    worldfactor(t) = WorldSmoothed(1,t);
    
    for r = 1:Regions
       RegionSmoother = P0RegionsSave(:,:,r,t)*PhiRegions(:,:,r)'/RegionVarPredicts(:,:,r,t);
       RegionSmoothed(:,r, t) = RegionUpdates(:,r,t) + RegionSmoother*(RegionSmoothed(:,r,t+1) - RegionPredictsSave(:,r,t+1));
       RegionVarianceSmoothed(:,:,r,t) = P0RegionsSave(:,:,r,t) - RegionSmoother*( RegionVarianceSmoothed(:,:,r,t+1) - RegionVarPredicts(:,:,r,t))*RegionSmoother';
    end
    regionalfactors(:,t) = RegionSmoothed(1, :, t)';
    
    for c = 1:Countries
        CountrySmoother = P0CountriesSave(:,:,c,t)*PhiCountries(:,:,c)'/CountryVarPredicts(:,:,c,t);
        CountrySmoothed(:,c,t) = CountryUpdates(:,c,t) + CountrySmoother*(CountrySmoothed(:,c,t+1) - CountryPredictsSave(:,c,t+1));
        CountryVarianceSmoothed(:,:,c,t) = P0CountriesSave(:,:,c,t) - CountrySmoother*(CountryVarianceSmoothed(:,:,c,t+1) - CountryVarPredicts(:,:,c,t))*CountrySmoother;
    end
    countryfactors(:, t) = CountrySmoothed(1,:,t)';
    
end

end
