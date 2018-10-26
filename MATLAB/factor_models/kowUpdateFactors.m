function [  ] = kowUpdateFactors(demeanedy, ObsModel, ...
    SparseObservationCovar, TransitionWorld, TransitionRegion,...
    TransitionCountry, regionIndices)
T = size(demeanedy,1);
K = size(SparseObservationCovar,1); 
Regions = 7;
Countries = 60;
ObsCovDiag = spdiags(SparseObservationCovar,0);
RegionPredicts = zeros(Regions,T);
RegionVarPredicts = zeros(Regions,T);
CountryPredicts= zeros(Countries, T);
CountryVarPredicts = zeros(Countries, T);


selectCountryEqns = 1:3;

country = 0;
region = 0;
WorldVar0 = eye(3).*[1;.5;.25];
RegionVar0 = zeros(3,3, Regions) + WorldVar0;
CountryVar0 = zeros(3,3,Countries) + WorldVar0;
regionFactor0 = zeros(3,Regions);
countryFactor0 = zeros(3, Countries);
worldFactor0 = zeros(3,1);
restrictedVariance = 1;
muregion = zeros(K,1);
mucountry = muregion;
size(ObsModel)

tempRegionPredictions = zeros(Regions,1);
tempCountryPredictions = zeros(Countries,1);
tempRegionVars = zeros(Regions,1);
tempCountryVars = zeros(Countries,1);
for t = 1:1
    % Step 1 predict, update 3 factors, world, region, country
    % Factors are all ar3's
    WorldPredict = TransitionWorld*worldFactor0;
    WorldVarPredict = TransitionWorld*WorldVar0*TransitionWorld' + restrictedVariance;
    muworld = ObsModel(:,1)*WorldPredict;
    
    for r = 1:Regions
        first=regionIndices(r,1);
        last=regionIndices(r,2);
        RegionPredicts(r,t) = TransitionRegion(r,:)*regionFactor0(:,r);
        RegionVarPredicts(r,t) = TransitionRegion(r,:) * RegionVar0(:,:,r) * TransitionRegion(r,:)' + restrictedVariance;
        muregion(first:last) = ObsModel(first:last,2)*RegionPredicts(r,t);
    end
    
    for c = 1:Countries
        indices = selectCountryEqns + (c-1)*3;
        CountryPredicts(c,t) = TransitionCountry(c,:)*countryFactor0(:,c);
        CountryVarPredicts(c,t) = TransitionCountry(c,:) * CountryVar0(:,:,c) * TransitionCountry(c,:)' + restrictedVariance;
        mucountry(indices) = ObsModel(indices, 3) * CountryPredicts(c,t);
    end
    
    
    
    resid = demeanedy(t,:)' - (muworld + muregion + mucountry);
    
    residvar = ObsModel(:,1)*WorldVarPredict*ObsModel(:,1)' + SparseObservationCovar;
    WorldKalman = WorldVarPredict * ObsModel(:,1)'/residvar;
    worldFactor0 = [worldFactor0(2:end); WorldPredict + WorldKalman*resid];
    WorldVarPredict - WorldKalman*ObsModel(:,1)*WorldVarPredict
    
    for r = 1:Regions
        first=regionIndices(r,1);
        last=regionIndices(r,2);
        G = ObsModel(first:last,2);
        residvar =  G*RegionVarPredicts(r,t)*G' + diag(ObsCovDiag(first:last));
        RegionKalman = RegionVarPredicts(r,t)*G'/residvar;
        tempRegionPredictions(r) = RegionPredicts(r,t) + RegionKalman*resid(first:last);
        tempRegionVars(r) = RegionVarPredicts(r,t) - RegionKalman*G*RegionVarPredicts(r,t);
    end
    regionFactor0 = [regionFactor0(2:end,:); tempRegionPredictions'];
    for c = 1:Countries
        indices = selectCountryEqns + (c-1)*3;
        G = ObsModel(indices,3);
        residvar = G*CountryVarPredicts(c,t)*G' + diag(ObsCovDiag(indices));
        CountryKalman = CountryVarPredicts(c,t)*G'/residvar;
        tempCountryPredictions(c) = CountryPredicts(c,t) + CountryKalman*resid(indices);
        tempCountryVars(c) = CountryVarPredicts(c,t) - CountryKalman*G*CountryVarPredicts(c,t);
    end


%     
% 
% 

%     RegionVarPredicts(:,t) - RegionKalman*ObsModel(:,2).*RegionVarPredicts(:,t)
%     CountryKalman = CountryVarPredicts(t,:)'*ObsModel(:,3)'/SparseObservationCovar;
%     countryFactor0 = [countryFactor0(2:end,:); (CountryPredicts(t,:)' + CountryKalman*resid)'];
%     WorldResidualVariance = ObsModel(:,1) * WorldPredictedVariance * ObsModel(:,1)' + SparseObservationCovar;

    
 

%     stateVarPredictSave(t) = stateVarPredict;
% 
%     % Step 2 update
%     resid = demeanedy(select) - ObsModel*statePredict;
%     residvar = ObsModel*stateVarPredict*ObsModel' + FullSigma;
% 
%     % Filter
%     KalmanGain = stateVarPredict*ObsModel'/residvar;
%     state0 = statePredict + KalmanGain*resid;
%     stateUpdateSave(t) = state0;
%     stateVar0 = stateVarPredict - KalmanGain*ObsModel*stateVarPredict;
%     stateVarUpdateSave(t) = stateVar0;
    
end
% smoothedState = zeros(T,1);
% smoothedState(T) = state0;
% smoothedStateVar =zeros(T,1);
% smoothedStateVar(T) = stateVar0;
% for t = (T-1):-1:1
%    Smootht = stateVarUpdateSave(t)*...
%        StateTransition'*(1/stateVarPredictSave(t+1));
%    smoothedState(t) = stateUpdateSave(t) + ...
%        Smootht*(smoothedState(t+1) -...
%        StateTransition*stateUpdateSave(t));
%    smoothedStateVar(t) = stateVarUpdateSave(t) - ...
%        (Smootht*(smoothedStateVar(t+1) -...
%        stateVarUpdateSave(t+1))*Smootht');
% end

end
