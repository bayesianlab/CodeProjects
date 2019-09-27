function [sumFt, sumFt2, sumOM, sumOM2, sumOtherOM, sumOtherOM2,...
    sumST, sumST2,sumBeta, sumBeta2, sumObsVariance, sumObsVariance2,...
    sumFactorVar, sumFactorVar2, varianceDecomp, ml] = NoBlocks(yt, Xt,  InfoCell, Sims,...
    burnin, ReducedRuns, initFactor, initBeta, initobsmodel,...
    initStateTransitions, v0, r0, s0, d0, identification, estML, DotMatFile)
periodloc = strfind(DotMatFile, '.') ;
checkpointdir = join( [ '~/CodeProjects/MATLAB/factor_models/MLFVAR/Checkpoints/',...
    DotMatFile(1:periodloc-1), 'Checkpoints/'] );

checkpointfilename = 'ckpt';
start = 1;
saveFrequency = 50;
finishedMainRun = 0;
finishedFirstReducedRun = 0;
finishedSecondReducedRun = 0;
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
otherOM = currobsmod;
Ft = initFactor;
StateObsModel = makeStateObsModel(currobsmod,Identities,0);
Si = kowStatePrecision(diag(initStateTransitions),factorVariance,T);
factorVariance = ones(nFactors,1);
% variancedecomp = zeros(K,levels);
% storeVarDecomp = zeros(K, levels, Sims-burnin);
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
sumOM = zeros(K, levels);
sumOM2= sumOM ;
sumOtherOM = zeros(K, levels);
sumOtherOM2 = zeros(K, levels);
sumFactorVar = zeros(nFactors,1);
sumFactorVar2 = sumFactorVar;
% sumVarianceDecomp = variancedecomp;
% sumVarianceDecomp2 = variancedecomp;
storeFactorParamb = zeros(nFactors, Sims-burnin);
sumBackup = backupMeanAndHessian;

options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-14, 'Display', 'off', 'OptimalityTolerance', 1e-14);

levelVec = 1:levels;

if exist(checkpointdir, 'dir')
    ckptfilename = join([checkpointdir, checkpointfilename, '.mat']);
    if exist(ckptfilename, 'file')
        fprintf('Found a checkpoint file\n')
        load(ckptfilename)
        fprintf('Loaded checkpoint file\n')
    end
else
    fprintf('Created a checkpoint dir in %s', checkpointdir')
    mkdir(checkpointdir)
end

if finishedMainRun == 0
    for iterator = start : Sims
        if mod(iterator, saveFrequency) == 0
            fprintf('File saved at iteration count %i\n', iterator)
            start = iterator;
            save(join( [checkpointdir, 'ckpt'] ) )
        end
        
        fprintf('\nSimulation %i\n',iterator)
        
        [beta, xbt, ~, ~] = kowBetaUpdate(yt(:), Xt, obsPrecision,...
            StateObsModel, Si,  T);
        
        for q = levelVec
            fprintf('Level %i\n', q)
            ConditionalObsModel = makeStateObsModel(currobsmod, Identities, q);
            mut = xbt + ConditionalObsModel*Ft;
            ydemut = yt - mut;
            Info = InfoCell{1,q};
            factorIndx = factorInfo(q,:);
            factorSelect = factorIndx(1):factorIndx(2);
            factorVarianceSubset = factorVariance(factorSelect);
            tempbackup = backupMeanAndHessian(factorSelect,:);
            
            [currobsmod(:,q), tempbackup, f, otherOM(:,q)] = AmarginalF(Info, ...
                Ft(factorSelect, :), ydemut, currobsmod(:,q), ...
                stateTransitions(factorSelect), factorVarianceSubset,...
                obsPrecision, tempbackup,  otherOM(:,q), options);
            
            backupMeanAndHessian(factorSelect,:) = tempbackup;
            Ft(factorSelect,:) = f;
        end
        
        StateObsModel = makeStateObsModel(currobsmod,Identities,0);
        
        %% Variance
        resids = yt - StateObsModel*Ft - xbt;
        [obsVariance,r2] = kowUpdateObsVariances(resids, v0,r0,T);
        obsPrecision = 1./obsVariance;
        
        %% AR Parameters
        stateTransitions = kowUpdateArParameters(stateTransitions, Ft, factorVariance, 1);
        Si = kowStatePrecision(diag(stateTransitions),factorVariance,T);
        
        if identification == 2
            [factorVariance, factorParamb]  = drawFactorVariance(Ft, stateTransitions, s0, d0);
        end
        %% Storage
        if iterator > burnin
            v = iterator - burnin;
            sumFt = sumFt + Ft;
            sumFt2 = sumFt2 + Ft.^2;
            sumBeta = sumBeta + beta;
            sumBeta2 = beta.^2 + sumBeta2;
            sumObsVariance = sumObsVariance +  obsVariance;
            sumObsVariance2 = sumObsVariance2 + obsVariance.^2;
            sumOM= sumOM + currobsmod;
            sumOM2 = sumOM2 + currobsmod.^2;
            sumOtherOM = sumOtherOM + otherOM;
            sumOtherOM2 = sumOtherOM2 + otherOM.^2;
            sumST = sumST + stateTransitions;
            storeStateTransitions(:,:,v) = stateTransitions;
            sumST2 = sumST2 + stateTransitions.^2;
            sumResiduals2 = sumResiduals2 + r2;
            sumFactorVar = sumFactorVar + factorVariance;
            sumFactorVar2 = sumFactorVar2 + factorVariance.^2;
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
    sumOtherOM = sumOtherOM./Runs;
    sumOtherOM2= sumOtherOM2./Runs;
    sumST = sumST./Runs;
    sumST2 = sumST2 ./Runs;
    sumResiduals2 = sumResiduals2 ./Runs;
    sumFactorVar = sumFactorVar./Runs;
    sumFactorVar2 = sumFactorVar2./Runs;
    
    %% Variance Decompositions and resizing. (Hopefully
    % Resizing gets removed, it is unneccessary.
    reducedDimBackUps  = backupMeanAndHessian;
    varianceDecomp = zeros(K,levels);
    facCount = 1;
    for k = levelVec
        factorIndx = factorInfo(k,:);
        factorSelect = factorIndx(1):factorIndx(2);
        [reducedDimBackUps(factorSelect,:), sumBackup(factorSelect,:)] =...
            reduceDimBackup(InfoCell{1,k}, backupMeanAndHessian(factorSelect,:), sumBackup(factorSelect,:));
        Info = InfoCell{1,k};
        Regions = size(Info,1);
        vydemut = var(yt,[],2);
        for r = 1:Regions
            subsetSelect = Info(r,1):Info(r,2);
            varianceDecomp(subsetSelect,k) = var(sumOM(subsetSelect,k).*sumFt(facCount,:),[],2);;
            facCount = facCount + 1;
        end
    end
    
    Gt = makeStateObsModel(sumOM, Identities, 0);
    mut =  reshape(Xt*sumBeta,K,T);
    vresids = var(yt - mut - Gt*sumFt,[],2);
    vtot = sum([varianceDecomp,vresids],2);
    varianceDecomp = varianceDecomp./vtot;
    %% Marginal Likelihood
    [K,T] = size(yt);
    obsPrecisionStar = 1./sumObsVariance;
    piObsVarianceStar = logigampdf(sumObsVariance, .5.*(T+v0), .5.*(sumResiduals2 + r0));
    piFactorVarianceStar = logigampdf(sumFactorVar, .5.*(T+s0), .5.*(d0+mean(storeFactorParamb,2)));
    piFactorTransitionStar = kowArMl(storeStateTransitions, sumST, sumFt, sumFactorVar);
    Ag = zeros(K,levels,ReducedRuns);
    Betag = zeros(dimX, ReducedRuns);
    Sstar =  kowStatePrecision(diag(sumST), sumFactorVar,T);
    currobsmod = sumOM;
    finishedMainRun = 1;
    startRR = 1;
    save(join( [checkpointdir, 'ckpt'] ) )
end

if estML == 1
    if finishedFirstReducedRun == 0
        for r = startRR:ReducedRuns
            fprintf('Reduced Run %i\n', r)
            if mod(r, saveFrequency) == 0
                fprintf('File saved at iteration count %i\n', r)
                startRR = r;
                save(join( [checkpointdir, 'ckpt'] ) )
            end
            [~, xbt, ~, ~] = kowBetaUpdate(yt(:), Xt, obsPrecisionStar,...
                StateObsModel, Sstar,  T);
            for q = levelVec
                ConditionalObsModel = makeStateObsModel(currobsmod, Identities, q);
                mut = xbt + ConditionalObsModel*sumFt;
                ydemut = yt - mut;
                Info = InfoCell{1,q};
                factorIndx = factorInfo(q,:);
                factorSelect = factorIndx(1):factorIndx(2);
                factorVarianceSubset = sumFactorVar(factorSelect);
                tempbackup = reducedDimBackUps(factorSelect,:);
                [currobsmod(:,q), tempbackup, ~] = AmarginalF_ML(Info, ...
                    sumFt(factorSelect, :), ydemut, currobsmod(:,q), sumST(factorSelect),...
                    factorVarianceSubset,obsPrecisionStar, tempbackup,...
                    options);
                reducedDimBackUps(factorSelect,:) = tempbackup;
            end
            Ag(:,:,r) = currobsmod;
            StateObsModel = makeStateObsModel(currobsmod,Identities,0);
        end
    end
    Astar = mean(Ag,3);
    StateObsModelStar = makeStateObsModel(Astar,Identities,0);
    bhatmean = zeros(1,dimX);
    VarSum = zeros(dimX,dimX);
    if finishedFirstReducedRun == 0
        finishedFirstReducedRun = 1;
        save(join( [checkpointdir, 'ckpt'] ) )
    end
    
    startRR = 1;
    if finishedSecondReducedRun == 0
        for r = startRR:ReducedRuns
            fprintf('Reduced Run %i\n', r)
            if mod(r, saveFrequency) == 0
                fprintf('File saved at iteration count %i\n', r)
                startRR = iterator;
                save(join( [checkpointdir, 'ckpt'] ) )
            end
            [beta, ~, bhat, Variance] = kowBetaUpdate(yt(:), Xt, obsPrecisionStar,...
                StateObsModelStar, Sstar,  T);
            Betag(:,r) = beta;
            bhatmean = bhatmean + bhat';
            VarSum = VarSum + Variance;
        end
        BetaStar = mean(Betag,2);
        piBetaStar = logmvnpdf(BetaStar', bhatmean./ReducedRuns, VarSum./ReducedRuns);
        piAstarsum = 0;
        priorAstar = zeros(1,levels);
        mutStar = reshape(Xt*BetaStar,K,T);
        for q = levelVec
            ConditionalObsModel = makeStateObsModel(Astar, Identities, q);
            mut = mutStar + ConditionalObsModel*sumFt;
            ydemut = yt - mut;
            priorAstar(q) = Apriors(Info,Astar);
            Info = InfoCell{1,q};
            factorIndx = factorInfo(q,:);
            factorSelect = factorIndx(1):factorIndx(2);
            factorVarianceSubset = sumFactorVar(factorSelect);
            tempbackup = sumBackup(factorSelect,:);
            piAstarsum = piAstarsum + sum(piAstar(Info, sumFt(factorSelect, :), ydemut, squeeze(Ag(:,q,:)),...
                Astar, sumST(factorSelect), factorVarianceSubset,...
                obsPrecisionStar, tempbackup,identification));
        end
        finishedSecondReducedRun = 1;
        save(join( [checkpointdir, 'ckpt'] ) )
        
        fprintf('Computing Marginal Likelihood\n')
        
        posteriorStar = sum(piObsVarianceStar) +  sum(piFactorVarianceStar) ...
            + sum(piFactorTransitionStar) + piBetaStar + piAstarsum;
        
        mu = reshape(Xt*BetaStar,K,T) +  StateObsModelStar*sumFt ;
        LogLikelihood = sum(logmvnpdf(yt', mu', diag(sumObsVariance)));
        
        Kprecision = kowStatePrecision(diag(sumST), sumFactorVar, T);
        Fpriorstar = logmvnpdf(sumFt(:)', zeros(1,nFactors*T ), Kprecision\speye(nFactors*T));
        G = kron(eye(T), StateObsModelStar);
        J = Kprecision + G'*spdiags(repmat(obsPrecisionStar,T,1), 0, K*T, K*T)*G;
        piFtstarGivenyAndthetastar = .5*(  logdet(J) -  (log(2*pi)*nFactors*T)  );
        fyGiventhetastar =  LogLikelihood + Fpriorstar - piFtstarGivenyAndthetastar;
        
        priorST = sum(logmvnpdf(sumST, zeros(1,nFactors), eye(nFactors)));
        priorObsVariance = sum(logigampdf(sumObsVariance, .5.*v0, .5.*d0));
        priorFactorVar = sum(logigampdf(sumFactorVar, .5.*s0, .5.*d0));
        priorBeta = logmvnpdf(BetaStar', zeros(1, dimX), eye(dimX));
        priorStar = sum([priorST,priorObsVariance,priorFactorVar, sum(priorAstar),priorBeta ]);
        
        %     [LogLikelihood, piFtstarGivenyAndthetastar]
        %     priors = [priorST,priorObsVariance,priorFactorVar, priorAstar,priorBeta, Fpriorstar ]
        %     sum(priors)
        %     posteriors = [   sum(piObsVarianceStar) , sum(piFactorVarianceStar), ...
        %         sum(piFactorTransitionStar) , piBetaStar, piAstarsum]
        
        ml = fyGiventhetastar + priorStar - posteriorStar;
        fprintf('Marginal Likelihood of Model: %.3f\n', ml)
        save(join( [checkpointdir, 'ckpt'] ) )
    else
        fprintf('Marginal Likelihood of Model: %.3f\n', ml)
    end
else
    ml = 'nothing';
end

end

