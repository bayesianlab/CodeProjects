function [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2] = ...
    ...
    MultDyFacVar(yt, Xt,  InfoCell, Sims,...
    burnin, ReducedRuns, initFactor, initBeta, initobsmodel, initStateTransitions, v0, r0)

% InfoCell 1,1 has which country belongs to which Region
% InfoCell 1,2 has which equation starts a region and which
% ends a region in row pairs
% InfoCell 1,3 has SeriesPerCountry
% Number of rows is equal to countries in InfoCell 1,1
% yt is K x T
% Obs Model must be [World Region Country] and is K x 3

% Index information
InfoMat = InfoCell{1,1};
SeriesPerCountry = InfoCell{1,3};
nFactors = length(initStateTransitions);
[K,T] = size(yt);
betaDim= size(Xt,2);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
levels = length(sectorInfo);
Countries = sectorInfo(3);
Regions = sectorInfo(2);
backupMeanAndHessian  = setBackups(InfoCell);

% Parameter inits
currobsmod = initobsmodel;
StateObsModel = makeStateObsModel(currobsmod,Identities,0);
Si = kowStatePrecision( diag(initStateTransitions), 1, T);
obsPrecision = ones(K,1);
stateTransitions = initStateTransitions;
beta = initBeta;
Ft = initFactor;

% Storage containers
sumFt = zeros(nFactors, T);
sumFt2 = sumFt.^2;
sumResiduals2 = zeros(K,1);
sumST = zeros(nFactors, 1);
sumST2 = zeros(nFactors, 1);
sumObsVariance = zeros(K,1);
sumObsVariance2 = sumObsVariance;
sumOM = zeros(K, 3);
sumOM2= sumOM ;
sumBeta = zeros(betaDim, 1);
sumBeta2 = sumBeta;

options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-10, 'Display', 'off', 'OptimalityTolerance', 1e-9);

DisplayHelpfulInfo(K,T,Regions,Countries,...
    nFactors,  Sims,burnin,ReducedRuns, options);

for i = 1 : Sims
    fprintf('\nSimulation %i\n',i)
    [beta, ydemut] = kowBetaUpdate(yt(:), Xt, obsPrecision,...
        StateObsModel, Si,  T);
    
    for q = 1:levels
        ConditionalObsModel = makeStateObsModel(currobsmod, Identities, q);
        ty = ydemut - ConditionalObsModel*Ft;
        Info = InfoCell{1,q};
        factorIndx = factorInfo(q,:);
        factorSelect = factorIndx(1):factorIndx(2);
        tempbackup = backupMeanAndHessian(factorSelect,:);
        [currobsmod(:,q), tempbackup, f] = AmarginalF(Info, ...
            Ft(factorSelect, :), ty, currobsmod(:,q), stateTransitions(factorSelect), obsPrecision, ...
            tempbackup, options);
        backupMeanAndHessian(factorSelect,:) = tempbackup;
        Ft(factorSelect,:) = f;
    end
    
    StateObsModel = makeStateObsModel(currobsmod,Identities,0);
    %      vecFt  =  kowUpdateLatent(yt(:),  StateObsModel, kowStatePrecision(diag(stateTransitions),1,T), obsPrecision);
    %     Ft = reshape(vecFt, nFactors,T);
    %% Variance
    residuals = ydemut - StateObsModel*Ft;
    [obsVariance,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
    obsPrecision = 1./obsVariance;
    
    %% AR Parameters
    stateTransitions = kowUpdateArParameters(stateTransitions, Ft, 1);
    
    %% Storage
    if i > burnin
        v = i - burnin;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
        sumBeta = sumBeta + beta;
        sumBeta2 = sumBeta2 + beta.^2;
        sumObsVariance = sumObsVariance +  obsVariance;
        sumObsVariance2 = sumObsVariance2 + obsVariance.^2;
        sumOM= sumOM + currobsmod;
        sumOM2 = sumOM2 + currobsmod.^2;
        sumST = sumST + stateTransitions;
        storeStateTransitions(:,:,v) = stateTransitions;
        sumST2 = sumST2 + stateTransitions.^2;
        sumResiduals2 = sumResiduals2 + r2;
    end
    
end

Runs = Sims- burnin;
sumFt = sumFt./Runs;
sumFt2 = sumFt2./Runs;
sumBeta = sumBeta./Runs;
sumBeta2 = sumBeta2./Runs;
sumObsVariance = sumObsVariance./Runs;
sumObsVariance2 = sumObsVariance2 ./Runs;
sumOM= sumOM ./Runs;
sumOM2 = sumOM2 ./Runs;
sumST = sumST./Runs;
sumST2 = sumST2 ./Runs;
sumResiduals2 = sumResiduals2 ./Runs;

obsPrecisionStar = 1./sumObsVariance;

% MLFML(yt,Xt, sumST, sumObsVariance, nFactors)

end

