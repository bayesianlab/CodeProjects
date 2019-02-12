function [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2] = ...
    ...
    MDFM(yt, Xt,  InfoCell, Sims,...
    burnin, ReducedRuns, initBeta, initobsmodel, initStateTransitions, v0, r0)





nFactors = length(initStateTransitions);
[K,T] = size(yt);
betaDim= size(Xt,2);
[Imat] = MakeObsIdentities( InfoCell, K);

% backupMeanAndHessian  = setBackups(InfoCell, SeriesPerCountry, worldBlocks,2);





Si = kowStatePrecision( diag(initStateTransitions), 1, T);
obsPrecision = ones(K,1);
stateTransitions = initStateTransitions;
beta = initBeta;
currobsmod = initobsmodel;

FactorIndices = SetIndicesInFactor(InfoCell);
StateObsModel = MakeObsModel(currobsmod, Imat, FactorIndices);
RestrictedIndices = RestrictionsInVectorizedMean(InfoCell, FactorIndices);




vecF = kowUpdateLatent(yt(:), StateObsModel, Si, obsPrecision) ;
Ft = reshape(vecF, nFactors,T);
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
ydemut = yt;

DispInfo(K,T,nFactors, Sims,burnin,ReducedRuns)



options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
    'Display', 'iter', 'FiniteDifferenceType', 'forward',...
    'MaxIterations', 100, 'MaxFunctionEvaluations', 5000,...
    'OptimalityTolerance', 1e-3, 'FunctionTolerance', 1e-5, 'StepTolerance', 1e-5);

tp = ones(1,nFactors*K);
tpp = eye(nFactors*K);



for i = 1 : Sims
    fprintf('\nSimulation %i\n',i)
    %     [beta, ydemut] = kowBetaUpdate(yt(:), Xt, obsPrecision,...
    %         StateObsModel,Si,T);
    
    
    currobsmod = AmF(currobsmod, ydemut,  tp, tpp, obsPrecision,  Ft, Si, Imat, FactorIndices, RestrictedIndices, InfoCell, options);
    StateObsModel = MakeObsModel (currobsmod,Imat, FactorIndices);
    vecF = kowUpdateLatent(yt(:), StateObsModel, Si, obsPrecision) ;
    Ft = reshape(vecF, nFactors,T);

    %% Variance
    residuals = ydemut - StateObsModel*Ft;
    [obsVariance,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
    obsPrecision = 1./obsVariance;
    
    %% AR Parameters
    stateTransitions = kowUpdateArParameters(stateTransitions, Ft, 1);
    Si = kowStatePrecision( diag(stateTransitions), 1, T);
    %% Storage
    if i > burnin
        sumBeta = sumBeta + beta;
        sumBeta2 = sumBeta2 + beta.^2;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
        sumObsVariance = sumObsVariance +  obsVariance;
        sumObsVariance2 = sumObsVariance2 + obsVariance.^2;
        sumOM= sumOM + currobsmod;
        sumOM2 = sumOM2 + currobsmod.^2;
        sumST = sumST + stateTransitions;
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


