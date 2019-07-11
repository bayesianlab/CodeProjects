function [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
    sumVarianceDecomp2, storeParama] = ...
    ...
    Smdfvar(yt, Xt, InfoCell, CorrType, LocationCorrelation, cutpoints, Sims,...
    burnin, ReducedRuns, initFactor, initobsmodel,...
    initStateTransitions, v0, r0, s0, d0, parama, identification)
% Spatial version of MDFVAR
% yt is K x T


if CorrType == 1
    tuningVar = .5;
else
    tuningVar=  .025;
end

% Index information
[nFactors, arFactor] = size(initStateTransitions);
[K,T] = size(yt);
[~, dimX] = size(Xt);
rowsCorr = size(LocationCorrelation,1);
seriesPerY = K /rowsCorr ;
nGroups = K/seriesPerY;


levels = length(InfoCell);
backupMeanAndHessian  = setBackups(InfoCell, identification);
% % Initializatitons
LC = LocationCorrelation;
obsPrecision = ones(K,1);
stateTransitions = initStateTransitions;
currobsmod = setObsModel(initobsmodel, InfoCell, identification);
StateObsModel = currobsmod(:,1);
Ft = initFactor;
Si = kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T);
factorVariance = ones(nFactors,1);
variancedecomp = zeros(K,levels);
% Storage
sumFt = zeros(nFactors, T);
sumFt2 = sumFt;
sumBeta = zeros(dimX,1);
sumBeta2 = sumBeta;
sumResiduals2 = zeros(K,1);
storeStateTransitions = zeros(nFactors, arFactor, Sims-burnin);
sumST = zeros(nFactors, 1);
sumST2 = zeros(nFactors, 1);
sumObsVariance = zeros(K,1);
sumObsVariance2 = sumObsVariance;
sumOM = zeros(K, levels);
sumOM2= sumOM ;
sumFactorVar = zeros(nFactors,1);
sumFactorVar2 = sumFactorVar;
sumVarianceDecomp = variancedecomp;
sumVarianceDecomp2 = variancedecomp;
storeParama = zeros(Sims-burnin,1);
options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-10, 'Display', 'off', 'OptimalityTolerance', 1e-9);

% DisplayHelpfulInfo(K,T,nFactors,  Sims,burnin,ReducedRuns, options);
vy = var(yt,0,2);
eyeK = speye(K);
eyeT = speye(T);
for i = 1 : Sims
    fprintf('\nSimulation %i\n',i)
    
    [LocationCorrelation, ~] = createSpatialCorr(LC, parama, CorrType);
    
    LocationCorrelationPrecision = kron(eye(seriesPerY), LocationCorrelation\speye(rowsCorr));
    ItSigmaInverse = kron(eyeT, LocationCorrelationPrecision);
    ItA = kron(eyeT, StateObsModel);
    [beta, mu,~, ~] = timeBreaksBeta(yt, Xt, ItA, ItSigmaInverse, Si);
    ty = yt  - mu;
    [currobsmod(:), tempbackup, f, vdecomp] = ...
        Spatial_AmarginalF(eyeK, ...
        Ft, ty, currobsmod, stateTransitions,...
        factorVariance, backupMeanAndHessian,options, identification, vy);
    backupMeanAndHessian = tempbackup;
    Ft(1,:) = f;
    variancedecomp(:,1) = vdecomp;
    
    
    %% AR Parameters
    stateTransitions = kowUpdateArParameters(stateTransitions, Ft, factorVariance, 1);
    
    if identification == 2
        factorVariance = drawFactorVariance(Ft, stateTransitions, s0, d0);
    end
    
    %% Spatial Parameter
    parama = drawCorrParam(parama, tuningVar, cutpoints, CorrType,  yt,...
        StateObsModel, LC, Ft, seriesPerY);
    
    %% Storage
    if i > burnin
        v = i - burnin;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
        sumBeta = sumBeta + beta;
        sumBeta2 = sumBeta2 + beta.^2;
        sumOM= sumOM + currobsmod;
        sumOM2 = sumOM2 + currobsmod.^2;
        sumST = sumST + stateTransitions;
        storeStateTransitions(:,:,v) = stateTransitions;
        sumST2 = sumST2 + stateTransitions.^2;
        sumFactorVar = sumFactorVar + factorVariance;
        sumFactorVar2 = sumFactorVar2 + factorVariance.^2;
        sumVarianceDecomp = sumVarianceDecomp + variancedecomp;
        sumVarianceDecomp2 = sumVarianceDecomp2 + variancedecomp.^2;
        storeParama(v) = parama;
    end
    
    Si = kowStatePrecision(diag(stateTransitions),factorVariance,T);
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
sumVarianceDecomp = sumVarianceDecomp./Runs;
sumVarianceDecomp2 = sumVarianceDecomp2./Runs;
obsPrecisionStar = 1./sumObsVariance;

% MLFML(yt,Xt, sumST, sumObsVariance, nFactors)

end

