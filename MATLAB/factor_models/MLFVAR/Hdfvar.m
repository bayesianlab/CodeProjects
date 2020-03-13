function [storeFt, storeVAR, storeOM, storeStateTransitions,...
    storeObsPrecision, storeFactorVar,varianceDecomp, ml] =...
    Hdfvar(yt, Xt,  InfoCell,  Sims,burnin, initFactor, initobsmodel,...
    initStateTransitions, initObsPrecision, initFactorVar, beta0, B0,...
    v0, r0, s0, d0, a0, A0inv, g0,G0, identification, estML, DotMatFile)
periodloc = strfind(DotMatFile, '.') ;
checkpointdir = join( [ '~/CodeProjects/MATLAB/factor_models/MLFVAR/Checkpoints/',...
    DotMatFile(1:periodloc-1),'_Checkpoints/'] )
fprintf('Hdfvar Estimation\n')
checkpointfilename = 'ckpt';
start = 1;
saveFrequency = 50;
finishedMainRun = 0;
finishedFirstReducedRun = 0;
finishedSecondReducedRun = 0;
finishedThirdReducedRun = 0;
[nFactors, lagState] = size(initStateTransitions);
[K,T] = size(yt);
KT = K*T;
SurX = surForm(Xt,K);
[~, dimX] = size(Xt);
dimSurX = dimX*K;
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);
levels = length(sectorInfo);
[~,dimx]=size(Xt);
FtIndexMat = CreateFactorIndexMat(InfoCell);
subsetIndices = zeros(K,T);
for k = 1:K
    subsetIndices(k,:)= k:K:KT;
end

% Initializatitons
obsPrecision = initObsPrecision;
factorVariance = initFactorVar;
stateTransitions = initStateTransitions;
currobsmod = setObsModel(initobsmodel, InfoCell);
Ft = initFactor;
fakeX = zeros(T,1);
fakeB = zeros(1,1);



% Storage
Runs = Sims - burnin;
storeVAR = zeros(dimx,K,Runs);
storeOM = zeros(K, levels, Runs);
storeFt = zeros(nFactors, T, Runs);
storeStateTransitions = zeros(nFactors, lagState, Runs);
storeObsPrecision = zeros(K, Runs);
storeFactorVar = zeros(nFactors,Runs);
keepOmMeans = currobsmod;
keepOmVariances = currobsmod;
runningAvgOmMeans = zeros(K,levels);
runningAvgOmVars = ones(K,levels);

if exist(checkpointdir, 'dir')
    ckptfilename = join([checkpointdir, checkpointfilename, '.mat']);
    if exist(ckptfilename, 'file')
        fprintf('Found a checkpoint file\n')
        load(ckptfilename)
        fprintf('Loaded checkpoint file\n')
    end
else
    fprintf('Created a checkpoint dir in %s\n', checkpointdir')
    mkdir(checkpointdir)
end


if finishedMainRun == 0
    for iterator = start : Sims
        if mod(iterator, saveFrequency) == 0
            fprintf('File saved at iteration count %i\n', iterator)
            start = iterator;
            save(join( [checkpointdir, 'ckpt'] ) )
        end
        fprintf('Simulation %i\n',iterator)
        %% Draw VAR params
        [VAR, Xbeta] = VAR_ParameterUpdate(yt, Xt, obsPrecision,...
            currobsmod, stateTransitions, factorVariance, beta0,...
            B0, FtIndexMat, subsetIndices);
        
        %% Draw loadings and factors
        [currobsmod, Ft, keepOmMeans, keepOmVariances]=...
            LoadingsFactorsUpdate(yt, Xbeta, Ft, currobsmod, stateTransitions,...
            obsPrecision, factorVariance, Identities, InfoCell, keepOmMeans, keepOmVariances,...
            runningAvgOmMeans, runningAvgOmVars, a0, A0inv);
        
        %% Variance
        StateObsModel = makeStateObsModel(currobsmod, Identities, 0);
        resids = yt - (StateObsModel*Ft) - Xbeta;
        obsVariance = kowUpdateObsVariances(resids, v0,r0,T);
        obsPrecision = 1./obsVariance;
        
        %% Factor AR Parameters
        for n=1:nFactors
            stateTransitions(n,:)= drawStateTransitions(stateTransitions(n,:), Ft(n,:), factorVariance(n), g0,G0);
        end
        
        if identification == 2
            factorVariance = drawFactorVariance(Ft, stateTransitions, factorVariance, s0, d0);
        end
        
        %% Storage
        if iterator > burnin
            v = iterator - burnin;
            storeVAR(:,:,v)=VAR;
            storeOM(:,:,v) = currobsmod;
            storeStateTransitions(:,:,v) = stateTransitions;
            storeFt(:,:,v) = Ft;
            storeObsPrecision(:,v) = obsPrecision;
            storeFactorVar(:,v) = factorVariance;
            runningAvgOmMeans = (runningAvgOmMeans.*(v-1) + keepOmMeans)/v;
            runningAvgOmVars = (runningAvgOmVars.*(v-1) + keepOmVariances)/v;
        else
            runningAvgOmMeans=keepOmMeans;
            runningAvgOmVars=keepOmVariances;
        end
    end
    
    
    Runs = Sims- burnin;
    betaBar = reshape(mean(storeVAR,3), dimx*K,1);
    Ftbar = mean(storeFt,3);
    omBar = mean(storeOM,3);
    %% Variance Decompositions
    varMu = var(reshape(SurX*betaBar,K,T), [],2);
    facCount = 1;
    vd = zeros(size(currobsmod,1),size(currobsmod,2));
    for k = 1:levels
        Info = InfoCell{1,k};
        Regions = size(Info,1);
        for r = 1:Regions
            subsetSelect = Info(r,1):Info(r,2);
            vd(subsetSelect,k) = var(omBar(subsetSelect,k).*Ftbar(facCount,:),[],2);
            facCount = facCount + 1;
        end
    end
    varianceDecomp = [varMu,vd];
    varianceDecomp = varianceDecomp./sum(varianceDecomp,2);
    
    %%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%
    %% Marginal Likelihood
    %%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%
    
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
        storeObsPrecisiong = storeObsPrecision;
        storeStateTransitionsg = storeStateTransitions;
        storeVARj = storeVAR;
        storeFtj = storeFt;
        storeObsPrecisionj = storeObsPrecision;
        storeFactorVarj = storeFactorVar;
        storeStateTransitionsj = storeStateTransitions;
        stj = mean(storeStateTransitions,3);
        Ftj = mean(storeFt,3);
        obsPrecisionj = mean(storeObsPrecision,2);
        fvj = mean(storeFactorVar,2);
        [iP, ssState] =initCovar(stj, fvj);
        Si = FactorPrecision(ssState, iP, 1./fvj, T);
        %% MH for factor loadings
        fprintf('Reduced run for factor loadings\n')
        for r = startRR:Runs
            fprintf('RR = %i\n', r)
            [VAR, Xbeta] = VAR_ParameterUpdate(yt, Xt, obsPrecisionj,...
                Astar, stj, fvj, beta0, B0, FtIndexMat, subsetIndices);
            storeVARj(:,:,r) = VAR;
            Ftg = storeFt(:,:,r);
            stg = storeStateTransitionsg(:,:,r);
            opg = storeObsPrecisiong(:,r);
            
            [~, Ftj, keepOmMeans, keepOmVariances, stoAlphaj(:,r)] = ...
                LoadingsFactorsUpdate(yt,Xbeta,Ftj, Astar, stj,...
                obsPrecisionj,fvj, Identities, InfoCell, keepOmMeans, keepOmVariances,...
                runningAvgOmMeans, runningAvgOmVars, a0, A0inv);
            
            stoAlphag(:,r) = LoadingsFactorsCJ_GStep(Astar, storeOM(:,:,r), ...
                yt, Xbeta, Ftg, stg, opg, storeFactorVar(:,r), Identities,...
                InfoCell, runningAvgOmMeans, runningAvgOmVars, a0, A0inv);
            
            StateObsModel = makeStateObsModel(Astar,Identities,0);
            
            %% Variance
            resids = yt - StateObsModel*Ftj - Xbeta;
            obsVariance = kowUpdateObsVariances(resids, v0,r0,T);
            obsPrecisionj = 1./obsVariance;
            storeObsPrecisionj(:,r) = obsPrecisionj;
            
            %% State Transitions
            for n=1:nFactors
                stj(n,:) = drawStateTransitions(stateTransitions(n,:), Ftj(n,:), fvj(n), g0,G0);                
            end
            storeStateTransitionsj(:,:,r) = stj;
            
            if identification == 2
                [fvj, ~]  = drawFactorVariance(Ftj, stj, fvj,s0, d0);
                storeFactorVarj(:,r) = fvj;
            end
        end
        piA = sum(logAvg(stoAlphag) - logAvg(stoAlphaj));
        StateObsModelStar =  makeStateObsModel(Astar,Identities,0);
        stStar = mean(storeStateTransitionsg,3);
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
            [~, alphaj] = drawSTAlphaj(stStar, Ftj, fvj, g0, G0);
            alphag = drawSTAlphag(storeStateTransitionsg(:,:,r), stStar,...
                storeFtg(:,:,r), storeFactorVarg(:,r), g0, G0);
            stoAlphaj(:,r) = alphaj;
            stoAlphag(:,r) = alphag;
            if identification == 2
                [fvj, factorParamb]  = drawFactorVariance(Ftj, stStar, fvj, s0, d0);
                storeFactorVarj(:,r) = fvj;
            end
            [VAR, Xbeta] = VAR_ParameterUpdate(yt, Xt, obsPrecisionj,...
                Astar, stStar, fvj, beta0, B0, FtIndexMat, subsetIndices);
            storeVARj(:,:,r) = VAR;
            [iP, ssState] =initCovar(stStar, fvj);
            Si = FactorPrecision(ssState, iP, 1./fvj, T);
            vecy = reshape(yt-Xbeta, K*T,1);
            Ftj = reshape(kowUpdateLatent(vecy, StateObsModelStar,...
                Si, obsPrecisionj), nFactors, T);
            storeFtj(:,:,r) = Ftj;
            %% Variance
            resids = yt - StateObsModelStar*Ftj - Xbeta;
            obsVariance = kowUpdateObsVariances(resids, v0,r0,T);
            obsPrecisionj = 1./obsVariance;
            storeObsPrecisionj(:,r) = obsPrecisionj;
        end
        piST = sum(logAvg(stoAlphag) - logAvg(stoAlphaj));
        VARstar = mean(storeVARj,3);
        betaStar = reshape(VARstar, dimx*K,1);
        xbtStar = reshape(SurX*betaStar,K,T);
        ydemutStar = yt - xbtStar;
        storePiBeta = zeros(K,Runs);
        finishedSecondReducedRun = 1;
        save(join( [checkpointdir, 'ckpt'] ) )
    end
    %% Reduced Run for beta
    if finishedThirdReducedRun == 0
        fprintf('Reduced run for beta\n')
        for r = startRR:Runs
            fprintf('RR = %i\n', r)
            storePiBeta(:,r) = piBetaStar(VARstar, yt, Xt, obsPrecisionj,...
                Astar, stStar, fvj, beta0, B0, subsetIndices, FtIndexMat);
            Ftj = reshape(kowUpdateLatent(ydemutStar(:), StateObsModelStar,...
                Si,  obsPrecisionj), nFactors, T);
            storeFtj(:,:,r) = Ftj;
            %% Variance
            resids = yt - StateObsModelStar*Ftj - xbtStar;
            obsVariance= kowUpdateObsVariances(resids, v0,r0,T);
            obsPrecisionj = 1./obsVariance;
            storeObsPrecisionj(:,r) = obsPrecisionj;
            if identification == 2
                [fvj, ~]  = drawFactorVariance(Ftj, stStar, fvj, s0, d0);
                storeFactorVarj(:,r) = fvj;
            end
            [iP, ssState] =initCovar(stStar, fvj);
            Si = FactorPrecision(ssState, iP, 1./fvj, T);
        end
        piBeta = sum(logAvg(storePiBeta),1);
        obsPrecisionStar = mean(storeObsPrecisionj, 2);
        obsVarianceStar = 1./obsPrecisionStar;
        factorVarianceStar = mean(storeFactorVarj,2);
        finishedThirdReducedRun = 1;
        save(join( [checkpointdir, 'ckpt'] ) )
    end
    FtStar = mean(storeFtj,3);
    storePiFt = zeros(nFactors, Runs);
    muStar = StateObsModelStar*FtStar + xbtStar;
    residsStar = yt - muStar;
    r2Star = sum(residsStar.*residsStar,2);
    fprintf('Reduced run for Factor\n')
    for r = startRR:Runs
        fprintf('RR = %i\n', r)
        obsVariance = kowUpdateObsVariances(residsStar, v0,r0,T);
        obsPrecisionj = 1./obsVariance;
        storeObsPrecisionj(:,r) = obsPrecisionj;
        if identification == 2
            [fvj, ~]  = drawFactorVariance(FtStar, stStar, fvj, s0, d0);
            storeFactorVarj(:,r) = fvj;
        end
        storePiFt(:,r) = piFtStar(FtStar, yt, xbtStar, Astar, stStar,...
            obsPrecisionj, fvj, Identities, InfoCell);
    end
    
    piFt = sum(logAvg(storePiFt));
    obsPrecisionStar = mean(storeObsPrecisionj,2);
    factorVarianceStar = mean(storeFactorVarj,2);
    piObsVariance = sum(logigampdf(1./obsPrecisionStar, .5.*(v0+T), .5.*(r0+r2Star)));
    piFactorVariance = sum(piOmegaStar(factorVarianceStar, stStar, FtStar, s0,d0));
    
    posteriors = [piFt, piBeta, piA , piST, piObsVariance, piFactorVariance]
    posteriorStar = sum(posteriors)
    
    LogLikelihood=sum(logmvnpdf(residsStar', zeros(1,K), diag(obsVarianceStar)))
    
    priorST = sum(logmvnpdf(stStar, g0, G0));
    priorObsVariance = sum(logigampdf(obsVarianceStar, .5.*v0, .5.*r0));
    priorFactorVar = sum(logigampdf(factorVarianceStar, .5.*s0, .5.*d0));
    B0=diag(repmat(1./diag(B0), K,1));
    
    priorBeta = logmvnpdf(betaStar', beta0(:)', B0);
    priorAstar = Apriors(InfoCell, Astar, a0, A0inv);

    Fpriorstar = zeros(nFactors,1);
    for j = 1:nFactors
        [iP, ssFactorARStar] =initCovar(stStar(j,:), factorVarianceStar(j));
        Kprecision = FactorPrecision(ssFactorARStar, iP, 1./factorVarianceStar(j), T);
        Fpriorstar(j) = logmvnpdf(FtStar(j,:), zeros(1,T ), Kprecision\eye(T));
    end
    Fpriorstar=sum(Fpriorstar);
    priors = [Fpriorstar, priorST,priorObsVariance, priorFactorVar, sum(priorAstar), priorBeta]
    priorStar = sum(priors)
    
    
    ml = (LogLikelihood+priorStar)-posteriorStar;
    fprintf('Marginal Likelihood of Model: %.3f\n', ml)
    rmdir(checkpointdir, 's')
    
    %     fytheta = LogLikelihood + Fpriorstar - piFt;
    %     my = fytheta + sum([priorST,priorObsVariance, priorFactorVar, sum(priorAstar), priorBeta]) - sum([piBeta, piA , piST, piObsVariance, piFactorVariance])
else
    ml = 'nothing';
    rmdir(checkpointdir, 's')
end
fprintf('New Method Estimation\n')
end




