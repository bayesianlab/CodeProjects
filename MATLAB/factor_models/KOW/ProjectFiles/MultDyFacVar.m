function [sumFt, sumFt2, storeObsModel] = ...
    MultDyFacVar(yt, Xt,  InfoMat, SeriesPerCountry, Sims, burnin, initobsmodel, initStateTransitions, v0, r0)

% InfoMat is Countries: Region info in column 1,
% Country info in column 2
% Number of rows is equal to countries
% yt is K x T
% Obs Model must be [World Region Country] and is K x 3

nFactors = length(initStateTransitions);
[K,T] = size(yt);

[IRegion, ICountry, Regions, Countries] = MakeObsModelIdentity( InfoMat, SeriesPerCountry);

backupMeanAndHessian  = setBackups(InfoMat, SeriesPerCountry, 2);
RegionIndicesFt = 2:(Regions+1);

CountryIndicesFt = 2+Regions:(1+Regions+Countries);
StateObsModel = makeStateObsModel(initobsmodel,IRegion,ICountry);


Si = kowStatePrecision( diag(initStateTransitions), 1, T);
obsPrecision = ones(K,1);
stateTransitions = initStateTransitions;
currobsmod = initobsmodel;
storeObsModel = zeros(K, 3, Sims-burnin);
vecF = kowUpdateLatent(yt(:), StateObsModel, Si, obsPrecision) ;
Ft = reshape(vecF, nFactors,T);
sumFt = zeros(nFactors, T);
sumFt2 = sumFt;
zerooutregion = zeros(K, Regions);
zerooutcountry = zeros(K, Countries);
zerooutworld = zeros(K,1);

ydemut = yt;
for i = 1 : Sims
    fprintf('Simulation %i\n',i)
    %     [beta, ydemut] = kowBetaUpdate(yt(:), Xt, obsPrecision,...
    %         StateObsModel,Si,T);
    
    
    
    %     NoWorld = makeStateObsModel([zerooutworld, currobsmod(:,2:3)],IRegion,ICountry) ;
    %     NoRegion = makeStateObsModel(currobsmod, zerooutregion, ICountry);
    
    %     ynow = ydemut - NoWorld*Ft;
    %     ynor = ydemut - NoRegion*Ft;
    
    NoCountry = makeStateObsModel(currobsmod, IRegion, zerooutcountry);

    ty = ydemut - NoCountry*Ft;
    currobsmod(:,3) = AmarginalF(SeriesPerCountry, InfoMat, ...
        Ft(CountryIndicesFt, :), ty, currobsmod(:,3), stateTransitions(CountryIndicesFt), obsPrecision, ...
        backupMeanAndHessian);
    Ft(CountryIndicesFt,:) = kowUpdateLatent(ty(:), currobsmod(:,3).*ICountry,...
        kowStatePrecision(stateTransitions(CountryIndicesFt).*eye(Countries), 1,T), obsPrecision);
    
    NoRegion = makeStateObsModel(currobsmod, zerooutregion, ICountry);
    ty = ydemut - NoRegion*Ft;
    currobsmod(:,2) = AmarginalF(SeriesPerCountry, InfoMat, ...
        Ft(RegionIndicesFt, :), ty, currobsmod(:,2), stateTransitions(RegionIndicesFt), obsPrecision, ...
        backupMeanAndHessian);
    Ft(RegionIndicesFt,:) = kowUpdateLatent(ty(:), currobsmod(:,2).*IRegion,...
        kowStatePrecision(stateTransitions(RegionIndicesFt).*eye(Regions), 1,T), obsPrecision);

    NoWorld = makeStateObsModel([zerooutworld, currobsmod(:,2:3)],IRegion,ICountry) ;
    ty = ydemut - NoWorld*Ft;
    currobsmod(:,1) = AmarginalF(SeriesPerCountry, InfoMat, ...
        Ft(RegionIndicesFt, :), ty, currobsmod(:,2), stateTransitions(RegionIndicesFt), obsPrecision, ...
        backupMeanAndHessian);
    Ft(1,:) = kowUpdateLatent(ty(:), currobsmod(:,1),...
        kowStatePrecision(stateTransitions(1), 1,T), obsPrecision);

currobsmod
    StateObsModel = makeStateObsModel(currobsmod,IRegion,ICountry);
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
        
        %         storeBeta(:,v) = beta;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
        %         storeObsVariance(:,v) = obsVariance;
        storeObsModel(:,:,v) = currobsmod;
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

