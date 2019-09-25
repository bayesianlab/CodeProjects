function [sumFt, sumFt2, sumOM, sumOM2, sumST, sumST2,...
    sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2,sumVarianceDecomp,...
    sumVarianceDecomp2, ml] = ...
    ...
    Mdfvar_TimeBreaks(yt, Xt, InfoCell, Sims,burnin, ReducedRuns,...
    timeBreak, initFactor,  initobsmodel,initStateTransitions,...
    v0, r0, s0, d0, identification, estML)

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
backupMeanAndHessian1  = setBackups(InfoCell, identification);
backupMeanAndHessian2  = setBackups(InfoCell, identification);
% Initializatitons
factorVariance = ones(nFactors,1);
obsPrecision = ones(K,1);
stateTransitions = initStateTransitions;
currobsmod1 = setObsModel(initobsmodel, InfoCell, identification);
currobsmod2 = setObsModel(initobsmodel, InfoCell, identification);
com(:,:,1) = currobsmod1;
com(:,:,2) = currobsmod2;
Ft = initFactor;
StateObsModel = makeStateObsModel(currobsmod1,Identities,0);
ItA = kron(eye(T), StateObsModel);

ItSigmaInverse = kron(eye(T), diag(obsPrecision));
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
sumOM = zeros(K, levels, length(timeBreak)+1);
sumOM2= sumOM;

sumFactorVar = zeros(nFactors,1);
sumFactorVar2 = sumFactorVar;
sumVarianceDecomp = variancedecomp;
sumVarianceDecomp2 = variancedecomp;
storeFactorParamb = zeros(nFactors, Sims-burnin);
sumBackup1 = backupMeanAndHessian1;
sumBackup2 = backupMeanAndHessian2;

options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-14, 'Display', 'off', 'OptimalityTolerance', 1e-6);

% DisplayHelpfulInfo(K,T,nFactors,  Sims,burnin,ReducedRuns, options);
vy = var(yt,0,2);
if timeBreak == 0
    tb = 1;
    timeBreak = T;
else
    tb =1:length(timeBreak)+1;
end
levelVec = 1:levels;
for i = 1 : Sims
    tic
        fprintf('\nSimulation %i\n',i)
    [beta, xbt,~,~] = timeBreaksBeta(yt, Xt, ItA, ItSigmaInverse, Si);
    
    for t = tb
        if t == 1
            timeIndex = 1:timeBreak;
            ytTimeBreak = yt(:, timeIndex);
            FactorTimeBreak = Ft(:, timeIndex);
            xbtTimeBreak = xbt(:, timeIndex);
            backupMeanAndHessian = backupMeanAndHessian1;
        else
            timeIndex = timeBreak+1:T;
            ytTimeBreak = yt(:, timeIndex);
            FactorTimeBreak= Ft(:, timeIndex);
            xbtTimeBreak = xbt(:, timeIndex);
            backupMeanAndHessian = backupMeanAndHessian2;
        end
        for q = levelVec
            ConditionalObsModel = makeStateObsModel(com(:,:,t), Identities, q);
            mut = xbtTimeBreak + ConditionalObsModel*FactorTimeBreak;
            ydemut = ytTimeBreak - mut;
            Info = InfoCell{1,q};
            factorIndx = factorInfo(q,:);
            factorSelect = factorIndx(1):factorIndx(2);
            factorVarianceSubset = factorVariance(factorSelect);
            tempbackup = backupMeanAndHessian(factorSelect,:);
            [com(:,q,t), tempbackup, ~, ~] = AmarginalF(Info, ...
                FactorTimeBreak(factorSelect, :), ydemut, com(:,q,t),...
                stateTransitions(factorSelect), factorVarianceSubset,...
                obsPrecision, tempbackup, options, identification, vy);
            backupMeanAndHessian(factorSelect,:) = tempbackup;
            [f, vdecomp] = FgivenA(Info, ydemut, com(:,q,t),...
                stateTransitions(factorSelect), factorVarianceSubset,obsPrecision,  vy);
            Ft(factorSelect, timeIndex) = f;
        end
        if t == 1
            StateObsModel = makeStateObsModel(com(:,:,t),Identities,0);
            mu1 = StateObsModel*FactorTimeBreak + xbtTimeBreak;
            StateObsModel = makeStateObsModel(com(:,:,t),Identities, 0);
            ItA1 = kron(eye(timeBreak), StateObsModel);
            backupMeanAndHessian1 = backupMeanAndHessian;
        else
            StateObsModel = makeStateObsModel(com(:,:,t),Identities,0);
            mu2 = StateObsModel*FactorTimeBreak + xbtTimeBreak;
            resids = yt - [mu1,mu2];
            StateObsModel = makeStateObsModel(com(:,:,t),Identities, 0);
            ItA2= kron(eye(T-timeBreak), StateObsModel);
            ItA = blkdiag(ItA1, ItA2);
            backupMeanAndHessian2 = backupMeanAndHessian;
        end
    end
    
    %% Variance
    [obsVariance,r2] = kowUpdateObsVariances(resids, v0,r0,T);
    obsPrecision = 1./obsVariance;
    ItSigmaInverse = kron(eye(T), diag(obsPrecision));
    
    %% AR Parameters
    stateTransitions = kowUpdateArParameters(stateTransitions, Ft, factorVariance, 1);
    
    Si = kowStatePrecision(diag(initStateTransitions),factorVariance,T);
    
    if identification == 2
        [factorVariance, factorParamb]  = drawFactorVariance(Ft, stateTransitions, s0, d0);
    end
    
    %% Storage
    if i > burnin
        v = i - burnin;
        sumFt = sumFt + Ft;
        sumFt2 = sumFt2 + Ft.^2;
        sumBeta = sumBeta + beta;
        sumBeta2 = beta.^2 + sumBeta2;
        sumObsVariance = sumObsVariance +  obsVariance;
        sumObsVariance2 = sumObsVariance2 + obsVariance.^2;
        for t = tb
            sumOM(:,:,t) = sumOM(:,:,t) + com(:,:,t);
            sumOM2(:,:,t) = sumOM2(:,:,t) + com(:,:,t).^2;
        end
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
                sumBackup1(factorSelect,:) = sumLastMeanHessian(InfoCell{1,q},...
                    backupMeanAndHessian1(factorSelect,:), sumBackup1(factorSelect,:));
                sumBackup2(factorSelect,:) = sumLastMeanHessian(InfoCell{1,q},...
                    backupMeanAndHessian2(factorSelect,:), sumBackup2(factorSelect,:));
            end
        end
    end
    toc
end

Runs = Sims- burnin;
sumBeta = sumBeta./Runs;
sumBeta2 = sumBeta2./Runs;
sumBackup1 = cellfun(@(b)rdivide(b,Runs), sumBackup1, 'UniformOutput', false);
sumBackup2 = cellfun(@(b)rdivide(b,Runs), sumBackup2, 'UniformOutput', false);
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

%% Marginal Likelihood
[K,T] = size(yt);
obsPrecisionStar = 1./sumObsVariance;
piObsVarianceStar = logigampdf(sumObsVariance, .5.*(T+v0), .5.*(sumResiduals2 + r0));
piFactorVarianceStar = logigampdf(sumFactorVar, .5.*(T+s0), .5.*(d0+mean(storeFactorParamb,2)));
piFactorTransitionStar = kowArMl(storeStateTransitions, sumST, sumFt, sumFactorVar);
Ag1 = zeros(K,levels,ReducedRuns);
Ag2= zeros(K,levels,ReducedRuns);
Betag = zeros(dimX, ReducedRuns);
Sstar =  kowStatePrecision(diag(sumST), sumFactorVar,T);
ItSigmaInverseStar = kron(eye(T), diag(obsPrecisionStar));
% currobsmod = sumOM;
if estML == 1
    for r = 1:ReducedRuns
        %         fprintf('Reduced Run %i\n', r)
        [~, xbt,~,~] = timeBreaksBeta(yt, Xt, ItA, ItSigmaInverseStar, Sstar);
        for t = tb
            if t == 1
                timeIndex = 1:timeBreak;
                ytTimeBreak = yt(:, timeIndex);
                FactorTimeBreak = sumFt(:, timeIndex);
                xbtTimeBreak = xbt(:, timeIndex);
                
            else
                timeIndex = timeBreak+1:T;
                ytTimeBreak = yt(:, timeIndex);
                FactorTimeBreak= sumFt(:, timeIndex);
                xbtTimeBreak = xbt(:, timeIndex);
            end
            for q = levelVec
                ConditionalObsModel = makeStateObsModel(com(:,:,t), Identities, q);
                mut = xbtTimeBreak + ConditionalObsModel*FactorTimeBreak;
                ydemut = ytTimeBreak - mut;
                Info = InfoCell{1,q};
                factorIndx = factorInfo(q,:);
                factorSelect = factorIndx(1):factorIndx(2);
                factorVarianceSubset = sumFactorVar(factorSelect);
                tempbackup = backupMeanAndHessian(factorSelect,:);
                [com(:,q,t), tempbackup, ~, ~] = AmarginalF(Info, ...
                    FactorTimeBreak(factorSelect, :), ydemut, com(:,q,t), sumST(factorSelect), factorVarianceSubset,...
                    obsPrecisionStar, tempbackup, options, identification, vy);
                backupMeanAndHessian(factorSelect,:) = tempbackup;
            end
            if t == 1
                Ag1(:,:,r) = com(:,:,t);
                StateObsModel = makeStateObsModel(com(:,:,t),Identities,0);
                ItA1 = kron(eye(timeBreak), StateObsModel);
                
            else
                Ag2(:,:,r) = com(:,:,t);
                StateObsModel = makeStateObsModel(com(:,:,t),Identities, 0);
                ItA2= kron(eye(T-timeBreak), StateObsModel);
                ItA = blkdiag(ItA1, ItA2);
            end
        end
    end
    Astar1 = mean(Ag1,3);
    Astar2 = mean(Ag2,3);
    StateObsModel = makeStateObsModel(Astar1,Identities,0);
    ItA1 = kron(eye(timeBreak), StateObsModel);
    StateObsModel = makeStateObsModel(Astar2,Identities, 0);
    ItA2= kron(eye(T-timeBreak), StateObsModel);
    ItAstar = blkdiag(ItA1, ItA2);
    
    bhatmean = zeros(1,dimX);
    VarSum = zeros(dimX,dimX);
    for r = 1:ReducedRuns
        %         fprintf('Reduced Run %i\n', r)
        [beta, xbt,bhat,Variance] = timeBreaksBeta(yt, Xt, ItAstar, ItSigmaInverseStar, Sstar);
        Betag(:,r) = beta;
        bhatmean = bhatmean + bhat';
        VarSum = VarSum + Variance;
    end
    BetaStar = mean(Betag,2);
    piBetaStar = logmvnpdf(BetaStar', bhatmean./ReducedRuns, VarSum./ReducedRuns);
    piAstarsum = 0;
    for q = levelVec
        for t = 1:2
            if t == 1
                timeIndex = 1:timeBreak;
                ytTimeBreak = yt(:, timeIndex);
                FactorTimeBreak = sumFt(:, timeIndex);
                xbtTimeBreak = xbt(:, timeIndex);
                Astar = Astar1;
                Ag = Ag1;
                sumBackup = sumBackup1;
                
            else
                timeIndex = timeBreak+1:T;
                ytTimeBreak = yt(:, timeIndex);
                FactorTimeBreak= sumFt(:, timeIndex);
                xbtTimeBreak = xbt(:, timeIndex);
                Astar = Astar2;
                Ag = Ag2;
                sumBackup = sumBackup2;
            end
            ConditionalObsModel = makeStateObsModel(Astar, Identities, q);
            mut = xbtTimeBreak + ConditionalObsModel*FactorTimeBreak;
            ydemut = ytTimeBreak - mut;
            priorAstar = Apriors(Info,Astar);
            Info = InfoCell{1,q};
            factorIndx = factorInfo(q,:);
            factorSelect = factorIndx(1):factorIndx(2);
            factorVarianceSubset = sumFactorVar(factorSelect);
            tempbackup = sumBackup(factorSelect,:);
            piAstarsum = piAstarsum + sum(piAstar(Info, FactorTimeBreak(factorSelect, :),...
                ydemut, squeeze(Ag(:,q,:)),Astar, sumST(factorSelect), factorVarianceSubset,...
                obsPrecisionStar, tempbackup,identification));
        end
    end
    fprintf('Computing Marginal Likelihood\n')
    
    posteriorStar = sum(piObsVarianceStar) +  sum(piFactorVarianceStar) ...
        + sum(piFactorTransitionStar) + piBetaStar + piAstarsum;
    
%     posteriors = [   sum(piObsVarianceStar) , sum(piFactorVarianceStar) ,...
%         sum(piFactorTransitionStar) , piBetaStar, piAstarsum]
    
    mu = reshape(Xt*BetaStar,K,T) +  reshape(ItAstar*sumFt(:), K, T) ;
    LogLikelihood = sum(logmvnpdf(yt', mu', diag(sumObsVariance)));

    Kprecision = kowStatePrecision(diag(sumST), sumFactorVar, T);
    Fpriorstar = logmvnpdf(sumFt(:)', zeros(1,nFactors*T ), Kprecision\speye(nFactors*T));
    J = Kprecision + ItAstar'*spdiags(repmat(obsPrecisionStar,T,1), 0, K*T, K*T)*ItAstar;

    piFtstarGivenyAndthetastar = .5*(  logdet(J) -  (log(2*pi)*nFactors*T)  );
    fyGiventhetastar =  LogLikelihood + Fpriorstar - piFtstarGivenyAndthetastar;
    
    priorST = sum(logmvnpdf(sumST, zeros(1,nFactors), eye(nFactors)));
    priorObsVariance = sum(logigampdf(sumObsVariance, v0, d0));
    priorFactorVar = sum(logigampdf(sumFactorVar, s0, d0));
    priorBeta = logmvnpdf(BetaStar', zeros(1, dimX), eye(dimX));
    priorStar = sum([priorST,priorObsVariance,priorFactorVar, priorAstar,priorBeta ]);
    
%     priors = [priorST,priorObsVariance,priorFactorVar, priorAstar,priorBeta, Fpriorstar ]
    
    ml = fyGiventhetastar + priorStar - posteriorStar;
    
    fprintf('Marginal Likelihood of Model: %.3f\n', ml)
else
    ml = 'nothing';
end

end

