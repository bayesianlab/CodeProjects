function [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
   sumVarianceDecomp2] = ...
    ...
    MultDyFacVar(yt, Xt,  InfoCell, Sims,...
    burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
    initStateTransitions, v0, r0, s0, d0, identification, estML)

% InfoCell 1,1 has which country belongs to which Region
% InfoCell 1,2 has which equation starts a region and which
% ends a region in row pairs
% InfoCell 1,3 has SeriesPerCountry
% Number of rows is equal to countries in InfoCell 1,1
% yt is K x T
% Obs Model must be [World Region Country] and is K x 3

% Index information
[nFactors, arFactor] = size(initStateTransitions);
[K,T] = size(yt);
[~, dimX] = size(Xt);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
levels = length(sectorInfo);
backupMeanAndHessian  = setBackups(InfoCell, identification);

% Initializatitons
factorVariance = ones(nFactors,1);
obsPrecision = ones(K,1);
stateTransitions = initStateTransitions;
currobsmod = setObsModel(initobsmodel, InfoCell, identification);
Ft = initFactor;
StateObsModel = makeStateObsModel(currobsmod,Identities,0);
Si = kowStatePrecision(diag(initStateTransitions),factorVariance,T);
factorVariance = ones(nFactors,1);
variancedecomp = zeros(K,levels);
% Storage
sumBeta = zeros(dimX,1);
sumBeta2 = sumBeta;
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
sumFactorVar = zeros(nFactors,1);
sumFactorVar2 = sumFactorVar;
sumVarianceDecomp = variancedecomp;
sumVarianceDecomp2 = variancedecomp;
storeFactorParamb = zeros(nFactors, Sims-burnin);
sumBackup = backupMeanAndHessian;


options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-10, 'Display', 'off', 'OptimalityTolerance', 1e-9);

DisplayHelpfulInfo(K,T,nFactors,  Sims,burnin,ReducedRuns, options);
vy = var(yt,0,2);

levelVec = 1:levels;
for i = 1 : Sims
    fprintf('\nSimulation %i\n',i)
    [beta, ydemut] = kowBetaUpdate(yt(:), Xt, obsPrecision,...
        StateObsModel, Si,  T);
    
    for q = levelVec
        ConditionalObsModel = makeStateObsModel(currobsmod, Identities, q);
        mut = ConditionalObsModel*Ft;
        Info = InfoCell{1,q};
        factorIndx = factorInfo(q,:);
        factorSelect = factorIndx(1):factorIndx(2);
        factorVarianceSubset = factorVariance(factorSelect);
        tempbackup = backupMeanAndHessian(factorSelect,:);
        
        [currobsmod(:,q), tempbackup, f, vdecomp] = AmarginalF(Info, ...
            Ft(factorSelect, :), ydemut, currobsmod(:,q), stateTransitions(factorSelect), factorVarianceSubset,...
            obsPrecision, tempbackup, options, identification, vy, mut);
        backupMeanAndHessian(factorSelect,:) = tempbackup;
        Ft(factorSelect,:) = f;
        variancedecomp(:,q) = vdecomp;
    end
    StateObsModel = makeStateObsModel(currobsmod,Identities,0);
    
    %% Variance
    residuals = ydemut - StateObsModel*Ft;
    [obsVariance,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
    obsPrecision = 1./obsVariance;
    
    %% AR Parameters
    stateTransitions = kowUpdateArParameters(stateTransitions, Ft, 1);
    
    if identification == 2
        factorVariance = drawFactorVariance(Ft, stateTransitions, s0, d0);
    end
    
    Si = kowStatePrecision(diag(initStateTransitions),factorVariance,T);
        
    if identification == 2
        [factorVariance, factorParamb]  = drawFactorVariance(Ft, stateTransitions, s0, d0);
    end
    %% Storage
    if i > burnin
        v = i - burnin;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
        sumObsVariance = sumObsVariance +  obsVariance;
        sumObsVariance2 = sumObsVariance2 + obsVariance.^2;
        sumOM= sumOM + currobsmod;
        sumOM2 = sumOM2 + sumOM.^2;
        sumST = sumST + stateTransitions;
        storeStateTransitions(:,:,v) = stateTransitions;
        sumST2 = sumST2 + stateTransitions.^2;
        sumResiduals2 = sumResiduals2 + r2;
        sumFactorVar = sumFactorVar + factorVariance;
        sumFactorVar2 = sumFactorVar2 + factorVariance.^2;
        sumVarianceDecomp = sumVarianceDecomp + variancedecomp;
        sumVarianceDecomp2 = sumVarianceDecomp2 + variancedecomp.^2;
        storeFactorParamb(:, v) =  factorParamb;
        
        if estML == 1
            for q = levelVec
                factorIndx = factorInfo(q,:);
                factorSelect = factorIndx(1):factorIndx(2);
                sumBackup(factorSelect,:) = sumLastMeanHessian(InfoCell{1,q}, backupMeanAndHessian(factorSelect,:), sumBackup(factorSelect,:));
            end
        end
        
    end
end



Runs = Sims- burnin;
sumBeta = sumBeta./Runs;
sumBeta2 = sumBeta2./Runs;
sumBackup = cellfun(@(b)rdivide(b,Runs), sumBackup, 'UniformOutput', false);
sumFt = sumFt./Runs;
sumFt2 = sumFt2./Runs;
sumObsVariance = sumObsVariance./Runs;
sumObsVariance2 = sumObsVariance2 ./Runs;
sumOM= sumOM ./Runs;
sumOM2 = sumOM2 ./Runs;
sumST = sumST./Runs;
sumVarianceDecomp = sumVarianceDecomp./Runs;
sumVarianceDecomp2 = sumVarianceDecomp2./Runs;
sumST2 = sumST2 ./Runs;
sumResiduals2 = sumResiduals2 ./Runs;

% MLFML(yt,Xt, sumST, sumObsVariance, nFactors)

end

