function [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
    sumVarianceDecomp2, storeParama] = ...
    SMDFVAR_SimVersion(yt,  InfoCell, SpatialInfo, CorrType, LocationCorrelation, cutpoints, Sims,...
    burnin, ReducedRuns, initFactor, initobsmodel,...
    initStateTransitions, v0, r0, s0, d0, identification)
% Spatial version of MDFVAR
% yt is K x T

parama = 1;
tuningVar=  .5;
% Index information
[nFactors, arFactor] = size(initStateTransitions);
[K,T] = size(yt);
rowsCorr = size(LocationCorrelation,1);
seriesPerY = K /rowsCorr ;
levels = length(InfoCell);
backupMeanAndHessian  = setBackups(InfoCell, identification);
[factorIden,~,factorInfo]  = MakeObsModelIdentity(InfoCell);
% % Initializatitons
LC = LocationCorrelation;
obsPrecision = ones(K,1);
obsVariance = obsPrecision;
stateTransitions = initStateTransitions;
currobsmod = setObsModel(initobsmodel, InfoCell, identification);
tbcom = currobsmod;
StateObsModel = makeStateObsModel(currobsmod, factorIden, 0);

Ft = initFactor;
Si = kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T);
factorVariance = ones(nFactors,1);
variancedecomp = zeros(K,levels);
% Storage
sumFt = zeros(nFactors, T);
sumFt2 = sumFt;
% sumBeta = zeros(dimX,1);
% sumBeta2 = sumBeta;
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

for i = 1 : Sims
    fprintf('\nSimulation %i\n',i)
    [LocationCorrelation, Lower] = createSpatialCorr(LC, parama, CorrType);
    

    LCinv = LocationCorrelation\eye(K)
    
    for q = 1:levels
%         Info = InfoCell{1,q};
%         factorIndx = factorInfo(q,:);
%         factorSelect = factorIndx(1):factorIndx(2);
%         factorVarianceSubset = factorVariance(factorSelect);
%         tempbackup = backupMeanAndHessian(factorSelect,:);
%         COM = makeStateObsModel(tbcom, factorIden, q);

% spatial_identification2(currobsmod,yt, , Ft, Si, ones(K,1), eye(K), options)

        

    end
    

    
    %% Variance
    residuals = yt - StateObsModel*Ft;
    [obsVariance,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
    obsPrecision = 1./obsVariance;
    
    %% AR Parameters
    stateTransitions = kowUpdateArParameters(stateTransitions, Ft, factorVariance, 1);
    Si = kowStatePrecision(diag(initStateTransitions),ones(nFactors,1),T);
    if identification == 2
        factorVariance = drawFactorVariance(Ft, stateTransitions, s0, d0);
    end
    
    %% Spatial Parameter
    parama = drawCorrParam(parama, tuningVar, cutpoints, CorrType,  yt,...
        StateObsModel, LC, Ft, seriesPerY)
    
    %% Storage
    if i > burnin
        v = i - burnin;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
        %             sumBeta = sumBeta + beta;
        %             sumBeta2 = sumBeta2 + beta.^2;
        sumObsVariance = sumObsVariance +  obsVariance;
        sumObsVariance2 = sumObsVariance2 + obsVariance.^2;
        sumOM= sumOM + currobsmod;
        sumOM2 = sumOM2 + currobsmod.^2;
        sumST = sumST + stateTransitions;
        storeStateTransitions(:,:,v) = stateTransitions;
        sumST2 = sumST2 + stateTransitions.^2;
        sumResiduals2 = sumResiduals2 + r2;
        sumFactorVar = sumFactorVar + factorVariance;
        sumFactorVar2 = sumFactorVar2 + factorVariance.^2;
        sumVarianceDecomp = sumVarianceDecomp + variancedecomp;
        sumVarianceDecomp2 = sumVarianceDecomp2 + variancedecomp.^2;
        storeParama(v) = parama;
    end
end


Runs = Sims- burnin;
sumFt = sumFt./Runs;
sumFt2 = sumFt2./Runs;
% sumBeta = sumBeta./Runs;
% sumBeta2 = sumBeta2./Runs;
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

