function [sumFt, sumFt2, storeBeta] = ...
    MultDyFacVar(yt, Xt,  InfoMat, SeriesPerCountry, Sims, burnin, initobsmodel, initStateTransitions, v0, r0)

% InfoMat is Countries: Region info in column 1,
% Country info in column 2
% Number of rows is equal to countries
% yt is K x T
% Obs Model must be [World Region Country] and is K x 3

nFactors = length(initStateTransitions);
[K,T] = size(yt);

[IRegion, ICountry, Regions, Countries] = MakeObsModelIdentity( InfoMat, SeriesPerCountry);

backupMeanAndHessian  = setBackups(InfoMat, SeriesPerCountry);
RegionIndicesFt = 2:(Regions+1);
CountryIndicesFt = 1+Regions:(1+Regions+Countries);
StateObsModel = makeStateObsModel(initobsmodel,IRegion,ICountry);


Si = kowStatePrecision( diag(initStateTransitions), 1, T);
obsPrecision = ones(K,1);
stateTransitions = initStateTransitions;
currobsmod = initobsmodel;

vecF = kowUpdateLatent(yt(:), StateObsModel, Si, obsPrecision) ;
Ft = reshape(vecF, nFactors,T);
sumFt = zeros(nFactors, T);
sumFt2 = sumFt;
zerooutregion = zeros(K, Regions);
zerooutcountry = zeros(K, Countries);
zerooutworld = zeros(K,1);
for i = 1 : Sims
    fprintf('Simulation %i\n',i)
    [beta, ydemut] = kowBetaUpdate(yt(:), Xt, obsPrecision,...
        StateObsModel,Si,T);
    
    
    currobsmod = AmarginalF(SeriesPerCountry, InfoMat, ...
        Ft, yt, currobsmod, stateTransitions, obsPrecision, IRegion,ICountry, ...
        backupMeanAndHessian);
    StateObsModel = makeStateObsModel(currobsmod,IRegion,ICountry);
    NoWorld = makeStateObsModel([zerooutworld, currobsmod(:,2:3)],IRegion,ICountry) ;
    NoRegion = makeStateObsModel(currobsmod, zerooutregion, ICountry);
    NoCountry = makeStateObsModel(currobsmod, IRegion, zerooutcountry)
    
    ynow = ydemut - NoWorld*Ft;
    ynor = ydemut - NoRegion*Ft;
    ynoc = ydemut - NoCountry*Ft;
    
    
    
    Ft(1,:) = kowUpdateLatent(ynow(:), currobsmod(:,1), kowStatePrecision(stateTransitions(1), 1,T), obsPrecision);
    Ft(2,:) = kowUpdateLatent(ynor(:), currobsmod(:,2), kowStatePrecision(stateTransitions(2), 1,T), obsPrecision);
    Ft(3,:) = kowUpdateLatent(ynoc(:), currobsmod(:,3), kowStatePrecision(stateTransitions(3), 1,T), obsPrecision);
    residuals = ydemut - StateObsModel*Ft;
    [obsVariance,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
    
    %         [WorldAr] = kowUpdateArParameters(stateTransitions(1), Ft(1,:), 1);
    %         [RegionAr] = kowUpdateArParameters(stateTransitions(RegionIndicesFt),...
    %         Ft(RegionIndicesFt,:), 1);
    %         [CountryAr] = kowUpdateArParameters(stateTransitions(CountryIndicesFt),...
    %         Ft(CountryIndicesFt,:), 1);
    %         stateTransitions = [WorldAr;RegionAr;CountryAr];
    
    if i > burnin
        v = i -burnin;
        
        storeBeta(:,v) = beta;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
        %         storeObsVariance(:,v) = obsVariance;
        %         storeObsModel(:,:,v) = currobsmod;
        %         storeStateTransitions(:,:,v) = stateTransitions;
        %         sumResiduals2 = sumResiduals2 + r2;
        %         sumLastHessianCountry = sumLastHessianCountry + lastHessianCountry;
        %         sumLastHessianRegion = sumLastHessianRegion + lastHessianRegion;
        %         sumLastHessianWorld = sumLastHessianWorld + lastHessianWorld;
        %         sumLastMeanCountry = sumLastMeanCountry + lastMeanCountry;
        %         sumLastMeanRegion = sumLastMeanRegion + lastMeanRegion;
        %         sumLastMeanWorld = sumLastMeanWorld + lastMeanWorld;
    end
    
end
Runs = Sims- burnin;
sumFt = sumFt./Runs;
sumFt2 = sumFt2./Runs;
end

