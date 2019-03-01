function [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2] = ...
    ...
    MultDyFacVarSimVersion(yt, Xt,  InfoCell, Sims,...
    burnin, ReducedRuns, initBeta, initobsmodel, initStateTransitions, v0, r0,...
    worldBlocks)

% yt is K x T
% initobsmodel must be [Level1, Level2,...] and is K x Levels
% initStateTransitions must be nFactors x p where
% p is the number of lagged factors in every Factor equation

[nFactors, arFactor] = size(initStateTransitions);
[K,T] = size(yt);
betaDim= size(Xt,2);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
levels = length(sectorInfo);
Countries = sectorInfo(3);
Regions = sectorInfo(2);
backupMeanAndHessian  = setBackups(InfoCell);
% Needs to be generalized
RegionIndicesFt = 2:Regions+1;
CountryIndicesFt = 2+Regions:Countries +Regions+ 1;



obsPrecision = ones(K,1);
stateTransitions = initStateTransitions;
beta = initBeta;
currobsmod = initobsmodel;

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
sumBeta = zeros(betaDim, 1);
sumBeta2 = sumBeta;


Ft = ones(nFactors,T);

% options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
%     'Display', 'off', 'FiniteDifferenceType', 'forward',...
%     'MaxIterations', 100, 'MaxFunctionEvaluations', 5000,...
%     'OptimalityTolerance', 1e-5, 'FunctionTolerance', 1e-5, 'StepTolerance', 1e-5);

options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-10, 'Display', 'off');

DisplayHelpfulInfo(K,T,Regions,Countries,...
    nFactors, worldBlocks, Sims,burnin,ReducedRuns, options);

for i = 1 : Sims
    fprintf('\nSimulation %i\n',i)
    
    %% Update loadings and factors
    for q = 1:levels
        ConditionalObsModel = makeStateObsModel(currobsmod, Identities, q);
        ty = yt - ConditionalObsModel*Ft;
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
    
    %% Variance
    residuals = yt - StateObsModel*Ft;
    [obsVariance,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
    obsPrecision = 1./obsVariance;
    
    %% AR Parameters
    stateTransitions = kowUpdateArParameters(stateTransitions, Ft, 1);
    
    %% Storage
    if i > burnin
        v = i - burnin;
        sumBeta = sumBeta + beta;
        sumBeta2 = sumBeta2 + beta.^2;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
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
MLMLDFVAR(ReducedRuns, yt,Xt,Ft,obsPrecisionStar, storeStateTransitions, sumOM, backupMeanAndHessian,InfoCell, options, v0, r0,1)
end

