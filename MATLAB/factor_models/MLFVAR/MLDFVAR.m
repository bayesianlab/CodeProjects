function [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumObsVariance, sumObsVariance2] = ...
    ...
    MLDFVAR(yt, InfoCell, InfoCell2, Sims,...
    burnin, ReducedRuns, initFactor, initobsmodel, initStateTransitions, v0, r0)
%% INPUT
% yt is K x T
% initobsmodel must be [Level1, Level2,...] and is K x Levels,
% Levels are the number of factors that appear in each equation
% initStateTransitions must be nFactors x p where
% p is the number of lagged factors in every Factor equation
% InfoCell is a cell matrix with:
% InfoCell{1,g} All the information about the beginning and ending
% indices of the equations in the gth sector stored as
% row 1 = [beg, end]
% row 2 = [beg, end]
% .
% .
% .
% row j = [beg, end]



% Index information
[nFactors, arFactor] = size(initStateTransitions);
[K,T] = size(yt);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
levels = length(sectorInfo);
Countries = sectorInfo(3);
Regions = sectorInfo(2);
blockIndices = InfoCell{1,3}
backupMeanAndHessian  = setBackups(InfoCell);

% Initializatitons
obsPrecision = ones(K,1);
stateTransitions = initStateTransitions;
currobsmod = initobsmodel;
Ft = initFactor;

% Storage
sumFt = zeros(nFactors, T);
sumFt2 = sumFt.^2;
sumResiduals2 = zeros(K,1);
storeStateTransitions = zeros(nFactors, arFactor, Sims-burnin);
sumST = zeros(nFactors, 1);
sumST2 = zeros(nFactors, 1);
sumObsVariance = zeros(K,1);
sumObsVariance2 = sumObsVariance;
sumOM = zeros(K, 3);
sumOM2= sumOM ;

options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-7, 'Display', 'off', 'OptimalityTolerance', 1e-7);

DisplayHelpfulInfo(K,T,Regions,Countries,...
    nFactors, Sims,burnin,ReducedRuns, options);

for i = 1 : Sims
    fprintf('\nSimulation %i\n',i)
    
    %% Update loadings
    [currobsmod, tempbackup] =ObsModelUpdate(InfoCell2, ...
        Ft, yt, currobsmod, stateTransitions, obsPrecision, ...
         backupMeanAndHessian, options, blockIndices);
%     backupMeanAndHessian(factorSelect,:) = tempbackup;
    
    StateObsModel = makeStateObsModel(currobsmod,Identities,0);
    vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, kowStatePrecision(diag(stateTransitions),1,T), obsPrecision);
    Ft = reshape(vecFt, nFactors,T);
    
    %% Variance
%     residuals = yt - StateObsModel*Ft;
%     [obsVariance,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
%     obsPrecision = 1./obsVariance;
    
    %% AR Parameters
%     stateTransitions = kowUpdateArParameters(stateTransitions, Ft, 1);
    
    %% Storage
    if i > burnin
        v = i - burnin;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
%         sumObsVariance = sumObsVariance +  obsVariance;
%         sumObsVariance2 = sumObsVariance2 + obsVariance.^2;
        sumOM= sumOM + currobsmod;
        sumOM2 = sumOM2 + currobsmod.^2;
        sumST = sumST + stateTransitions;
        storeStateTransitions(:,:,v) = stateTransitions;
        sumST2 = sumST2 + stateTransitions.^2;
%         sumResiduals2 = sumResiduals2 + r2;
    end
    
end

Runs = Sims- burnin;
sumFt = sumFt./Runs;
sumFt2 = sumFt2./Runs;
sumObsVariance = sumObsVariance./Runs;
sumObsVariance2 = sumObsVariance2 ./Runs;
sumOM= sumOM ./Runs;
sumOM2 = sumOM2 ./Runs;
sumST = sumST./Runs;
sumST2 = sumST2 ./Runs;

sumResiduals2 = sumResiduals2 ./Runs;
obsPrecisionStar = 1./sumObsVariance;

% MLFML(yt,Xt, sumST, sumObsVariance, nFactors)
% save('testdata')
% load('testdata.mat')
% MLMLDFVAR(ReducedRuns, yt,Xt,Ft,obsPrecisionStar, storeStateTransitions, sumOM, backupMeanAndHessian,InfoCell, options, v0, r0,1)
end

