function [storeFt, storeBeta, storeOM, storeStateTransitions,...
    storeObsPrecision, storeFactorVar,varianceDecomp, ml] =...
    NoBlocks(yt, Xt,  InfoCell, Sims,...
    burnin, initFactor, initobsmodel,...
    initStateTransitions, v0, r0, s0, d0, identification, estML, DotMatFile)
periodloc = strfind(DotMatFile, '.') ;
checkpointdir = join( [ '~/CodeProjects/MATLAB/factor_models/MLFVAR/Checkpoints/',...
    DotMatFile(1:periodloc-1),'Checkpoints/'] );

checkpointfilename = 'ckpt';
start = 1;
saveFrequency = 50;
finishedMainRun = 0;
finishedFirstReducedRun = 0;
finishedSecondReducedRun = 0;
finishedThirdReducedRun = 0;
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


% Storage
Runs = Sims - burnin;
storeBeta = zeros(dimX, Runs);
storeOM = zeros(K, levels, Runs);
storeFt = zeros(nFactors, T, Runs);
storeStateTransitions = zeros(nFactors, arFactor, Runs);
storeFactorParamb = zeros(nFactors, Runs);
storeObsPrecision = zeros(K, Runs);
storeFactorVar = zeros(nFactors,Runs);

sumBeta = zeros(dimX,1);
sumBeta2 = sumBeta;
sumFt = zeros(nFactors, T);
sumFt2 = sumFt.^2;
sumResiduals2 = zeros(K,1);
sumST = zeros(nFactors, 1);
sumST2 = zeros(nFactors, 1);
sumObsVariance = zeros(K,1);
sumObsVariance2 = sumObsVariance;
sumOM = zeros(K, levels);
sumOM2= sumOM ;

sumFactorVar = zeros(nFactors,1);
sumFactorVar2 = sumFactorVar;
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
            COM = makeStateObsModel(currobsmod, Identities, q);
            mut = xbt + COM*Ft;
            ydemut = yt - mut;
            Info = InfoCell{1,q};
            factorIndx = factorInfo(q,:);
            facSelect = factorIndx(1):factorIndx(2);
            facVarSubset = factorVariance(facSelect);
            tempbackup = backupMeanAndHessian(facSelect,:);
            
            [currobsmod(:,q), tempbackup, f] = AmarginalF(Info, ...
                Ft(facSelect, :), ydemut, currobsmod(:,q), ...
                stateTransitions(facSelect), facVarSubset,...
                obsPrecision, tempbackup, options, identification);
            backupMeanAndHessian(facSelect,:) = tempbackup;
            Ft(facSelect,:) = f;
        end
        
        
        StateObsModel = makeStateObsModel(currobsmod,Identities,0);
        Si = kowStatePrecision(diag(stateTransitions),1./factorVariance,T);
        
        %% Variance
        resids = yt - StateObsModel*Ft - xbt;
        [obsVariance,r2] = kowUpdateObsVariances(resids, v0,r0,T);
        obsPrecision = 1./obsVariance;
        
        %% AR Parameters
        stateTransitions = kowUpdateArParameters(stateTransitions, Ft, factorVariance, 1);
        
        if identification == 2
            [factorVariance, factorParamb]  = drawFactorVariance(Ft, stateTransitions, s0, d0);
        end
        %% Storage
        if iterator > burnin
            v = iterator - burnin;
            storeBeta(:, v) = beta;
            storeOM(:,:,v) = currobsmod;
            storeStateTransitions(:,:,v) = stateTransitions;
            storeFt(:,:,v) = sumFt;
            storeObsPrecision(:,v) = obsPrecision;
            storeFactorVar(:,v) = factorVariance;
            sumFt = sumFt + Ft;
            sumFt2 = sumFt2 + Ft.^2;
            sumBeta = sumBeta + beta;
            sumBeta2 = beta.^2 + sumBeta2;
            sumObsVariance = sumObsVariance +  obsVariance;
            sumObsVariance2 = sumObsVariance2 + obsVariance.^2;
            sumOM= sumOM + currobsmod;
            sumOM2 = sumOM2 + currobsmod.^2;
            sumST = sumST + stateTransitions;
            sumST2 = sumST2 + stateTransitions.^2;
            sumResiduals2 = sumResiduals2 + r2;
            sumFactorVar = sumFactorVar + factorVariance;
            sumFactorVar2 = sumFactorVar2 + factorVariance.^2;
            if identification == 2
                storeFactorParamb(:, v) =  factorParamb;
            end
            if estML == 1
                for q = levelVec
                    factorIndx = factorInfo(q,:);
                    facSelect = factorIndx(1):factorIndx(2);
                    sumBackup(facSelect,:) = sumLastMeanHessian(InfoCell{1,q}, backupMeanAndHessian(facSelect,:), sumBackup(facSelect,:));
                end
            end
            options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
                'StepTolerance', 1e-14, 'Display', 'off', 'OptimalityTolerance', 1e-14,...
                'MaxIterations', 5);
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
    sumST2 = sumST2 ./Runs;
    sumResiduals2 = sumResiduals2 ./Runs;
    sumFactorVar = sumFactorVar./Runs;
    sumFactorVar2 = sumFactorVar2./Runs;
    
    %% Variance Decompositions and resizing. (Hopefully
    % Resizing gets removed, it is unneccessary.
    
    vareps = var(reshape(Xt*sumBeta,K,T), [],2);
    facCount = 1;
    for k = 1:3
        Info = InfoCell{1,k};
        Regions = size(Info,1);
        for r = 1:Regions
            subsetSelect = Info(r,1):Info(r,2);
            vd(subsetSelect,k) = var(sumOM(subsetSelect,k).*sumFt(facCount,:),[],2);
            facCount = facCount + 1;
        end
    end
    varianceDecomp = [vareps,vd];
    varianceDecomp = varianceDecomp./sum(varianceDecomp,2);
    
    Gt = makeStateObsModel(sumOM, Identities, 0);
    mut =  reshape(Xt*sumBeta,K,T);
    vresids = var(yt - mut - Gt*sumFt,[],2);
    vtot = sum([varianceDecomp,vresids],2);
    varianceDecomp = varianceDecomp./vtot;
    
    %% Marginal Likelihood
    [K,T] = size(yt);
    finishedMainRun = 1;
    startRR = 1;
    save(join( [checkpointdir, 'ckpt'] ) )
end

if estML == 1
    if finishedFirstReducedRun == 0
        Astar = mean(storeOM,3);
        stoAlphaj = zeros(nFactors, Runs);
        stoAlphag = zeros(nFactors, Runs);
        storeBetag = storeBeta;
        storeFtg = storeFt;
        storeObsPrecisiong = storeObsPrecision;
        storeFactorVarg = storeFactorVar;
        storeStateTransitionsg = storeStateTransitions;
        storeBetaj = storeBeta;
        storeFtj = storeFt;
        storeObsPrecisionj = storeObsPrecision;
        storeFactorVarj = storeFactorVar;
        
        storeStateTransitionsj = storeStateTransitions;
        stj = mean(storeStateTransitions,3);
        Ftj = mean(storeFt,3);
        obsPrecisionj = mean(storeObsPrecision,2);
        fvj = mean(storeFactorVar,2);
        Si = kowStatePrecision(diag(stj),1./fvj,T);
        %% MH for factor loadings
        fprintf('Reduced run for factor loadings\n')
        for r = startRR:Runs
            fprintf('RR = %i\n', r)
            [betaj, xbtj, ~, ~] = kowBetaUpdate(yt(:), Xt, obsPrecisionj,...
                StateObsModel, Si,  T);
            storeBetaj(:,r) = betaj;
            Ftg = storeFtg(:,:,r);
            stg = storeStateTransitionsg(:,:,r);
            fv = storeFactorVar(:,r);
            opg = storeObsPrecisiong(:,r);
            betag = storeBetag(:,r);
            for q = levelVec
                ConditionalObsModel = makeStateObsModel(Astar, Identities, q);
                mutj = xbtj + ConditionalObsModel*Ftj;
                ydemut = yt - mutj;
                Info = InfoCell{1,q};
                factorIndx = factorInfo(q,:);
                facSelect = factorIndx(1):factorIndx(2);
                facVarSubset = fvj(facSelect);
                tempbackup = sumBackup(facSelect,:);
                [~, ~, f, alphaj] = AmarginalF_ML(Info, ...
                    Ftj(facSelect, :), ydemut,  Astar(:,q), stj(facSelect),...
                    facVarSubset,obsPrecisionj, tempbackup);
                stoAlphaj(facSelect, r) = alphaj;
                Ftj(facSelect,:) = f;
                omg = storeOM(:,:,r);
                ConditionalObsModel = makeStateObsModel(omg, Identities, q);
                mutg =  reshape(Xt*betag,K,T) + ConditionalObsModel*Ftg;
                ydemut = yt - mutg;
                stoAlphag(facSelect,r) = AmarginalF_alphag(Info,...
                    Ftg(facSelect,:), ydemut, Astar(:,q), omg(:,q),...
                    stg(facSelect,:), fv(facSelect),...
                    opg, tempbackup);
            end
            StateObsModel = makeStateObsModel(Astar,Identities,0);
            Si = kowStatePrecision(diag(stj),1./fvj,T);
            storeFtj(:,:,r) = Ftj;
            %% Variance
            resids = yt - StateObsModel*Ftj - xbtj;
            [obsVariance,r2] = kowUpdateObsVariances(resids, v0,r0,T);
            obsPrecisionj = 1./obsVariance;
            storeObsPrecisionj(:,r) = obsPrecisionj;
            
            %% State Transitions
            stj = kowUpdateArParameters(stj, Ftj, fvj, 1);
            storeStateTransitionsj(:,:,r) = stj;
            
            if identification == 2
                [fvj, factorParamb]  = drawFactorVariance(Ftj, stj, s0, d0);
                storeFactorVarj(:,r) = fvj;
            end
        end
        piA = logAvg(stoAlphag) - logAvg(stoAlphaj);
        piA = sum(piA);
        StateObsModelStar =  makeStateObsModel(Astar,Identities,0);
        stStar = mean(storeStateTransitionsg,3);
        storeBetag = storeBetaj;
        storeFtg = storeFtj;
        storeObsPrecisiong = storeObsPrecisionj;
        storeFactorVarg = storeFactorVarj;
        storeStateTransitionsg = storeStateTransitionsj;
        Ftj = mean(storeFtg,3);
        obsPrecisionj = mean(storeObsPrecisiong,2);
        fvj = mean(storeFactorVarg,2);
        stoAlphaj = zeros(nFactors, Runs);
        stoAlphag = zeros(nFactors, Runs);
        finishedFirstReducedRun = 1;
        save(join( [checkpointdir, 'ckpt'] ) )
    end
    %% MH Step for State Transitions
    
    if finishedSecondReducedRun == 0
        fprintf('Reduced run for state transitions\n')
        for r = startRR:Runs
            fprintf('RR = %i\n', r)
            [stj, alphaj] = drawSTAlphaj(stStar, Ftj, fvj,1);
            alphag = drawSTAlphag(storeStateTransitionsg(:,r), stStar,...
                storeFtg(:,:,r), storeFactorVarg(:,r), 1);
            storeStateTransitionsg(:,:,r) = stj;
            stoAlphaj(:,r) = alphaj;
            stoAlphag(:,r) = alphag;
            
            if identification == 2
                [fvj, factorParamb]  = drawFactorVariance(Ftj, stj, s0, d0);
                storeFactorVarj(:,r) = fvj;
            end
            Si = kowStatePrecision(diag(stj), 1./fvj, T);
            [betaj, xbtj, ~, ~] = kowBetaUpdate(yt(:), Xt, obsPrecisionj,...
                StateObsModelStar, Si,  T);
            storeBetaj(:,r) = betaj;
            vecy = reshape(yt-xbtj, K*T,1);
            Ftj = reshape(kowUpdateLatent(vecy, StateObsModelStar,...
                Si, obsPrecisionj), nFactors, T);
            storeFtj(:,:,r) = Ftj;
            StateObsModel = makeStateObsModel(Astar,Identities,0);
            %% Variance
            resids = yt - StateObsModel*Ft - xbtj;
            [obsVariance,r2] = kowUpdateObsVariances(resids, v0,r0,T);
            obsPrecisionj = 1./obsVariance;
            storeObsPrecisionj(:,r) = obsPrecisionj;
        end
        piST = sum(logAvg(stoAlphag) - logAvg(stoAlphaj));
        betaStar = mean(storeBetag,2);
        xbtStar = reshape(Xt*betaStar,K,T);
        ydemut = yt - xbtStar;
        storePiBeta = zeros(1,Runs);
        finishedSecondReducedRun = 1;
        save(join( [checkpointdir, 'ckpt'] ) )
    end
    %% Reduced Run for beta
    
    if finishedThirdReducedRun == 0
        fprintf('Reduced run for beta\n')
        for r = startRR:Runs
            fprintf('RR = %i\n', r)
            storePiBeta(r) = piBetaStar(betaStar, yt(:), Xt, obsPrecisionj,...
                StateObsModelStar, Si,  T);
            Ftj = reshape(kowUpdateLatent(ydemut(:), StateObsModelStar,...
                Si,  obsPrecisionj), nFactors, T);
            storeFtj(:,:,r) = Ftj;
            %% Variance
            resids = yt - StateObsModelStar*Ftj - xbtStar;
            [obsVariance,r2] = kowUpdateObsVariances(resids, v0,r0,T);
            obsPrecisionj = 1./obsVariance;
            storeObsPrecisionj(:,r) = obsPrecisionj;
            if identification == 2
                [fvj, factorParamb]  = drawFactorVariance(Ftj, stStar, s0, d0);
                storeFactorVarj(:,r) = fvj;
            end
            Si = kowStatePrecision(diag(stStar), 1./fvj, T);
        end
        piBeta = logAvg(storePiBeta);
        FtStar = mean(Ft,3);
        muStar = StateObsModelStar*FtStar + xbtStar;
        resids = yt - muStar;
        fMean = zeros(1, nFactors*T);
        storePiFactor = zeros(K,Runs);
        obsPrecisionStar = mean(storeObsPrecisionj, 2);
        obsVarianceStar = 1./obsPrecisionStar;
        factorVarianceStar = mean(storeFactorVarj,2);
        storePiObsVariance = zeros(K, Runs);
        storePiFactorVarianceStar = zeros(nFactors, Runs);
        finishedThirdReducedRun = 1;
        save(join( [checkpointdir, 'ckpt'] ) )
    end
    fprintf('Reduced run for obs variance and factor variance\n')
    for r = startRR:Runs
        fprintf('RR = %i\n', r)
        Si = kowStatePrecision(diag(stStar), 1./factorVarianceStar, T);
        Ftj = reshape(kowUpdateLatent(ydemut(:), StateObsModelStar,...
            Si,  obsPrecisionStar), nFactors, T);
        mutj = StateObsModelStar*Ftj + xbtStar;
        resids = yt - mutj;
        r2 = sum(resids.^2,2);
        storeFtj(:,:,r) = Ftj;
        storePiObsVariance(:,r) = logigampdf(obsVarianceStar, .5.*(v0+T), .5.*(r0+r2));
        obsPrecisionj = 1./obsVariance;
        storeObsPrecisionj(:,r) = obsPrecisionj;
        if identification == 2
            storePiFactorVarianceStar(:,r) = piOmegaStar(factorVarianceStar, stStar, Ftj, s0,d0);
        end
    end
    piObsVariance = sum(logAvg(storePiObsVariance));
    piFactorVariance = sum(logAvg(storePiFactorVarianceStar));
    FtStar = mean(Ft,3);
    LogLikelihood = sum(logmvnpdf(yt', muStar', diag(obsVarianceStar)));
    priorST = sum(logmvnpdf(stStar, zeros(1,nFactors), eye(nFactors)));
    priorObsVariance = sum(logigampdf(obsVarianceStar, .5.*v0, .5.*d0));
    priorFactorVar = sum(logigampdf(factorVarianceStar, .5.*s0, .5.*d0));
    priorBeta = logmvnpdf(betaStar', zeros(1, dimX), eye(dimX));
    priorAstar = Apriors(Info, Astar);
    priorStar = sum([priorST,priorObsVariance,priorFactorVar, sum(priorAstar),priorBeta ]);
    Kprecision = kowStatePrecision(diag(stStar), 1./factorVarianceStar, T);
    Fpriorstar = logmvnpdf(FtStar(:)', zeros(1,nFactors*T ), Kprecision\speye(nFactors*T));
    G = kron(eye(T), StateObsModelStar);
    J = Kprecision + G'*spdiags(repmat(obsPrecisionStar,T,1), 0, K*T, K*T)*G;
    piFtstarGivenyAndthetastar = .5*(  logdet(J) -  (log(2*pi)*nFactors*T)  );
    fyGiventhetastar =  LogLikelihood + Fpriorstar - piFtstarGivenyAndthetastar;
    posteriorStar = piBeta + piA + piST + piObsVariance + piFactorVariance;
    ml = fyGiventhetastar + priorStar - posteriorStar;
    fprintf('Marginal Likelihood of Model: %.3f\n', ml)
    rmdir(checkpointdir, 's')
else
    ml = 'nothing';
    rmdir(checkpointdir, 's')
end
end



