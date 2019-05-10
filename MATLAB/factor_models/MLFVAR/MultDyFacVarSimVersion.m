function [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumObsVariance, sumObsVariance2, sumVarianceDecomp,...
    sumVarianceDecomp2, ml] = ...
    ...
    MultDyFacVarSimVersion(yt, InfoCell, Sims,...
    burnin, ReducedRuns, initFactor, initobsmodel, initStateTransitions,...
    v0, r0, s0,d0, identification, estML)
%% INPUT
% % yt is K x T
% % initobsmodel must be [Level1, Level2,...] and is K x Levels,
% % Levels are the number of factors that appear in each equation
% % initStateTransitions must be nFactors x p where
% % p is the number of lagged factors in every Factor equation
% % InfoCell is a cell matrix with:
% % InfoCell{1,g} All the information about the beginning and ending
% % indices of the equations in the gth sector stored as
% % row 1 = [beg, end]
% % row 2 = [beg, end]
% % .
% % .
% % .
% % row j = [beg, end]
%
% % Index information

[nFactors, arFactor] = size(initStateTransitions);
[K,T] = size(yt);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
levels = length(sectorInfo);
Countries = sectorInfo(3);
Regions = sectorInfo(2);
backupMeanAndHessian  = setBackups(InfoCell, identification);

% Initializatitons
obsPrecision = ones(K,1);
obsVariance = obsPrecision;
stateTransitions = initStateTransitions;
currobsmod = setObsModel(initobsmodel, InfoCell, identification);
Ft = initFactor;
factorVariance = ones(nFactors,1);
variancedecomp = zeros(K,3);
r2 = 0;
factorParamb =0;
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

levelVec = 1:1;
% Ft = zeros(nFactors,T);
% Ft(1,:) = normrnd(0,1,1,T);
currobsmod(:,2:3) = zeros(K,2);
for i = 1 : Sims
    fprintf('\nSimulation %i\n',i)
    
    %% Update loadings and factors
    
    for q = levelVec
        ConditionalObsModel = makeStateObsModel(currobsmod, Identities, q);
        mut = ConditionalObsModel*Ft;
        ydemut = yt - mut;
        Info = InfoCell{1,q};
        factorIndx = factorInfo(q,:);
        factorSelect = factorIndx(1):factorIndx(2);
        factorVarianceSubset = factorVariance(factorSelect);
        tempbackup = backupMeanAndHessian(factorSelect,:);
        
        [currobsmod(:,q), tempbackup, f, vdecomp] = AmarginalF(Info, ...
            Ft(factorSelect, :), ydemut, currobsmod(:,q), stateTransitions(factorSelect), factorVarianceSubset,...
            obsPrecision, tempbackup, options, identification, vy);
        backupMeanAndHessian(factorSelect,:) = tempbackup;
        Ft(factorSelect,:) = f;
        variancedecomp(:,q) = vdecomp;
    end
    
    StateObsModel = makeStateObsModel(currobsmod,Identities,0);
    
    %% Variance
    ydemut = yt - StateObsModel*Ft;
    [obsVariance,r2] = kowUpdateObsVariances(ydemut, v0,r0,T);
    
    obsPrecision = 1./obsVariance;
    
    %% AR Parameters
    stateTransitions = kowUpdateArParameters(stateTransitions, Ft, 1);
    
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
sumFactorVar = sumFactorVar./Runs;
sumFactorVar2 = sumFactorVar2./Runs;

[K,T] = size(yt);
obsPrecisionStar = 1./sumObsVariance;
piObsVarianceStar = logigampdf(sumObsVariance, .5.*(T+v0), .5.*(sumResiduals2 + r0));
piFactorVarianceStar = logigampdf(sumFactorVar, .5.*(T+s0), .5.*(d0+mean(storeFactorParamb,2)));
piFactorTransitionStar = kowArMl(storeStateTransitions, sumST, sumFt);
Ag = zeros(K,levels,ReducedRuns);

%% Marginal Likelihood
if estML == 1
    for r = 1:ReducedRuns
        fprintf('Reduced Run %i\n', r)
        for q = levelVec
            ConditionalObsModel = makeStateObsModel(currobsmod, Identities, q);
            mut = ConditionalObsModel*Ft;
            Info = InfoCell{1,q};
            factorIndx = factorInfo(q,:);
            factorSelect = factorIndx(1):factorIndx(2);
            factorVarianceSubset = factorVariance(factorSelect);
            tempbackup = backupMeanAndHessian(factorSelect,:);
            [currobsmod(:,q), tempbackup, f, ~] = AmarginalF(Info, ...
                Ft(factorSelect, :), yt, currobsmod(:,q), stateTransitions(factorSelect), factorVarianceSubset,...
                obsPrecision, tempbackup, options, identification, vy, mut);
            backupMeanAndHessian(factorSelect,:) = tempbackup;
            Ft(factorSelect,:) = f;
            
        end
        Ag(:,:,r) = currobsmod;
    end
    Astar = mean(Ag,3);
    piAstarsum = 0;
    for q = levelVec
        priorAstar = Apriors(Info,Astar);
        Info = InfoCell{1,q};
        factorIndx = factorInfo(q,:);
        factorSelect = factorIndx(1):factorIndx(2);
        factorVarianceSubset = sumFactorVar(factorSelect);
        tempbackup = sumBackup(factorSelect,:);
        piAstarsum = piAstarsum + sum(piAstar(Info, Ft(factorSelect, :), yt, squeeze(Ag(:,q,:)),...
            Astar, sumST(factorSelect), factorVarianceSubset,...
            obsPrecisionStar, tempbackup,identification));
    end
    fprintf('Computing Marginal Likelihood\n')
    posteriorStar = sum(piObsVarianceStar) +  sum(piFactorVarianceStar) ...
        + sum(piFactorTransitionStar) +  piAstarsum;
    StateObsModelStar = makeStateObsModel(Astar, Identities, 0) ;
    
    mu = StateObsModelStar*sumFt ;
    LogLikelihood = sum(logmvnpdf(yt', mu', diag(sumObsVariance)));
    Kprecision = kowStatePrecision(diag(sumST), sumFactorVar, T);
    Fpriorstar = logmvnpdf(sumFt(:)', zeros(1,nFactors*T ), Kprecision\speye(nFactors*T));
    
    G = kron(eye(T), StateObsModelStar);
    J = Kprecision + G'*spdiags(repmat(obsPrecisionStar,T,1), 0, K*T, K*T)*G;
    piFtstarGivenyAndthetastar = .5*( logdet(J) -  (log(2*pi)*K*T)  );
    
    
    fyGiventhetastar =  LogLikelihood + Fpriorstar - piFtstarGivenyAndthetastar;
    
    priorST = sum(logmvnpdf(sumST, zeros(1,nFactors), 100.*eye(nFactors)));
    priorObsVariance = sum(logigampdf(sumObsVariance, v0, d0));
    priorFactorVar = sum(logigampdf(sumFactorVar, s0, d0));
    
    ml = fyGiventhetastar + priorST + priorObsVariance + priorFactorVar + priorAstar - posteriorStar;
    fprintf('Marginal Likelihood of Model: %f', ml)
else
    ml = 'nothing';
end
end


