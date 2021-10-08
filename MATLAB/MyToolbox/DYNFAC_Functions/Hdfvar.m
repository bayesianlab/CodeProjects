function [storeFt, storeVAR, storeOM, storeStateTransitions,...
    storeObsPrecision, storeFactorVar,varianceDecomp, ml, summary] =...
    Hdfvar(yt, Xt,  InfoCell,  Sims,burnin, initFactor, initobsmodel,...
    initStateTransitions, initObsPrecision, initFactorVar, beta0, B0inv,...
    v0, r0, s0, d0,  a0, A0inv, g0,G0, tau, identification, estML, DotMatFile)
% Statetransitions are stored [world;regions;country]

arerrors = 0;

nargin

[checkfr, checkfc] = size(initFactor);
[checkomr, checkomc] = size(initobsmodel);
[checkstr, checkstc] = size(initStateTransitions);
[checkopr, checkopc] = size(initObsPrecision);
[checkfvr, checkfvc] = size(initFactorVar);
checklevel = length(InfoCell)
if checkfr ~= checkfvr
    error('Each factor needs its own variance.')
end
if checkomc ~= checklevel
    error('Obs model does not have right number of levels.')
end
if checkopr ~= size(yt,1)
    error('yt has more/less equations than specified initial variances.')
end
if checkstr ~= checkfr
    error('Not enough state transitions.')
end

% periodloc = strfind(DotMatFile, '.') ;
% checkpointdir = join( [ '~/CodeProjects/MATLAB/MyToolbox/Checkpoints/',...
%     DotMatFile(1:periodloc-1),'_Checkpoints/'] )
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
restrictions = restrictedElements(InfoCell);
zerorestrictions = (restrictions < 0);
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
ap = zeros(nFactors,1);

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
g1bar = zeros(lagState,1)
G1bar = zeros(lagState);
% if exist(checkpointdir, 'dir')
%     ckptfilename = join([checkpointdir, checkpointfilename, '.mat']);
%     if exist(ckptfilename, 'file')
%         fprintf('Found a checkpoint file\n')
%         load(ckptfilename)
%         fprintf('Loaded checkpoint file\n')
%     end
% else
%     fprintf('Created a checkpoint dir in %s\n', checkpointdir')
%     mkdir(checkpointdir)
% end

Xbeta = zeros(K,T);
VAR = 0;
currobsmod = currobsmod.*.5;
obsPrecision = obsPrecision.*.5;
currobsmod(1) = 1 ;
StateObsModel = makeStateObsModel(currobsmod, Identities, 0);
P0 = initCovar(stateTransitions, 1/factorVariance); 
P = FactorPrecision(stateTransitions, P0, obsPrecision, T);
betaDraw(yt(:), SurX, obsPrecision, StateObsModel, P, 0, .01, T)

if finishedMainRun == 0
    for iterator = start : Sims
%         if mod(iterator, saveFrequency) == 0
%             fprintf('File saved at iteration count %i\n', iterator)
%             start = iterator;
%             save(join( [checkpointdir, 'ckpt'] ) )
%         end
        fprintf('Simulation %i\n',iterator)
        %% Draw VAR params
        
        [VAR, Xbeta] = VAR_ParameterUpdate(yt, Xt, obsPrecision,...
            currobsmod, stateTransitions, factorVariance, beta0,...
            B0inv, FtIndexMat, subsetIndices);
break 


        %% Draw loadings
        [currobsmod, Ft, ~, accept]=...
            LoadingsFactorsUpdate(yt, Xbeta, Ft, currobsmod, stateTransitions,...
            obsPrecision, factorVariance, Identities, InfoCell,  a0, A0inv, tau);
        currobsmod = currobsmod + restrictions - (currobsmod.*restrictions);
        currobsmod(zerorestrictions) = 0;
        

        %% Variance
        StateObsModel = makeStateObsModel(currobsmod, Identities, 0);
        resids = yt - (currobsmod*Ft) - Xbeta;

        obsVariance = kowUpdateObsVariances(resids, v0,r0,T);
        obsPrecision = 1./obsVariance;
        
     
        %% Factor AR Parameters
        for n=1:nFactors
            [stateTransitions(n,:), ~, g1, G1] = drawAR(stateTransitions(n,:), Ft(n,:), factorVariance(n),...
                g0, G0);
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
            g1bar = g1bar + g1;
            G1bar = G1bar + G1;
        end
%         ap = ap + accept;
    end
    
    Runs = Sims- burnin;
    accept_probability = ap./Sims;
    betaBar = reshape(mean(storeVAR,3), dimx*K,1);
    Ftbar = mean(storeFt,3);
    omBar = mean(storeOM,3);
    g1bar = g1bar./Runs;
    G1bar = G1bar./Runs;
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
%     save(join( [checkpointdir, 'ckpt'] ) )
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
        fvj = mean(storeFactorVar,2);
        [iP, ~, ~, w] =initCovar(stj, fvj);
        if w~=0
            iP = eye(length(stj));
        end
        Si = FactorPrecision(stj, iP, 1./fvj, T);
        
        [storeMeans, storeVars] = ComputeMeansVars(yt, Xbeta, Ft, Astar, stateTransitions,...
            obsPrecision, factorVariance, Identities, InfoCell,...
            a0, A0inv);
        
        opj = mean(storeObsPrecision,2);
        stj = mean(storeStateTransitionsj,3);
        fvj = mean(storeFactorVarj,2);
        
        %% MH for factor loadings
        fprintf('Reduced run for factor loadings\n')
        for r = startRR:Runs
            fprintf('RR = %i\n', r)
            Ftg = storeFt(:,:,r);
            stg = storeStateTransitionsg(:,:,r);
            opg = storeObsPrecisiong(:,r);
            betag = storeVAR(:,:,r);
            Xbetag = reshape(SurX*betag(:), K,T);
            fvg = storeFactorVar(:,r);
            stoAlphag(:,r) = LoadingsFactorsUpdate_GStep(Astar, storeOM(:,:,r), ...
                yt, Xbeta, Ftg, stg, opg, fvg, Identities, InfoCell,  a0, A0inv, ...
                storeMeans, storeVars);
            
            [VARj, Xbetaj] = VAR_ParameterUpdate(yt, Xt, opj,...
                Astar, stj, fvj, beta0, B0inv, FtIndexMat, subsetIndices);
            storeVARj(:,:,r) = VARj;
            StateObsModel = makeStateObsModel(Astar,Identities,0);
            %% Variance
            resids = yt - StateObsModel*Ftg - Xbetag;
            obsVariance = kowUpdateObsVariances(resids, v0,r0,T);
            obsPrecisionj = 1./obsVariance;
            storeObsPrecisionj(:,r) = obsPrecisionj;
            %% State Transitions
            for n=1:nFactors
                stj(n,:)= drawAR(stateTransitions(n,:), Ftj(n,:), fvj(n), g0,G0);
            end
            storeStateTransitionsj(:,:,r) = stj;
            if identification == 2
                [fvj, ~]  = drawFactorVariance(Ftj, stj, fvj,s0, d0);
                storeFactorVarj(:,r) = fvj;
            end
            [Ftj, stoAlphaj(:,r)] = LoadingsFactorsUpdate_Jstep(yt, Xbetaj, Ftj, Astar, stj,...
                obsPrecisionj,fvj, Identities, InfoCell,  storeMeans, storeVars, a0, A0inv);
            
        end
        piA = sum(logAvg(stoAlphag) - logAvg(stoAlphaj));
        StateObsModelStar =  makeStateObsModel(Astar,Identities,0);
        stStar = mean(storeStateTransitionsg,3);
        storeObsPrecisiong = storeObsPrecisionj;
        storeFactorVarg = storeFactorVarj;
        storeStateTransitionsg = storeStateTransitionsj;
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
            Ftg = storeFt(:,:,r);
            stg = storeStateTransitionsg(:,:,r);
            opg = storeObsPrecisiong(:,r);
            fvg = storeFactorVarg(:,r);
            stoAlphag(:,r) = drawSTAlpha_Gstep(stg, stStar, Ftg, fvg, g0, G0);
            
            Ftj = drawFactor(Ftj, yt, Xbeta, Astar, stateTransitions,...
                opg, factorVariance, Identities, InfoCell, arerrors);
            if identification == 2
                [fvj, ~]  = drawFactorVariance(Ftj, stStar, fvj, s0, d0);
                storeFactorVarj(:,r) = fvj;
            end
            [VARj, Xbetaj] = VAR_ParameterUpdate(yt, Xt, opj,...
                Astar, stStar, fvj, beta0, B0inv, FtIndexMat, subsetIndices);
            storeVARj(:,:,r) = VARj;
            storeFtj(:,:,r) = Ftj;
            %% Variance
            resids = yt - StateObsModelStar*Ftj - Xbetaj;
            obsVariancej = kowUpdateObsVariances(resids, v0,r0,T);
            obsPrecisionj = 1./obsVariancej;
            storeObsPrecisionj(:,r) = obsPrecisionj;
            for n = 1:nFactors
                stoAlphaj(n,r) = drawAR_Jstep(stStar(n,:), Ftj(n,:), fvj(n), g0, G0, g1bar, G1bar);
            end
        end
        storeFactorVarg = storeFactorVarj;
        piST = sum(logAvg(stoAlphag) - logAvg(stoAlphaj));
        VARstar = mean(storeVARj,3);
        betaStar = reshape(VARstar, dimx*K,1);
        xbtStar = reshape(SurX*betaStar,K,T);
        storePiBeta = zeros(K,Runs);
        finishedSecondReducedRun = 1;
        save(join( [checkpointdir, 'ckpt'] ) )
    end
    %% Reduced Run for beta
    if finishedThirdReducedRun == 0
        fprintf('Reduced run for beta\n')
        for r = startRR:Runs
            fprintf('RR = %i\n', r)
            opg = storeObsPrecisiong(:,r);
            fvg = storeFactorVarg(:,r);
            storePiBeta(:,r) = piBetaStar(VARstar, yt, Xt, opg,...
                Astar, stStar, fvg, beta0, B0inv, subsetIndices, FtIndexMat);
            
            Ftj = drawFactor(Ftj, yt, xbtStar, currobsmod, stateTransitions,...
                obsPrecisionj, fvj, Identities, InfoCell, arerrors);
            storeFtj(:,:,r) = Ftj;
            %% Variance
            resids = yt - StateObsModelStar*Ftj - xbtStar;
            obsVariancej= kowUpdateObsVariances(resids, v0,r0,T);
            obsPrecisionj = 1./obsVariancej;
            storeObsPrecisionj(:,r) = obsPrecisionj;
            if identification == 2
                [fvj, ~]  = drawFactorVariance(Ftj, stStar, fvj, s0, d0);
                storeFactorVarj(:,r) = fvj;
            end
            [iP, ~,~,w] =initCovar(stStar, fvj);
            if w~=0
                iP = eye(length(stStar));
            end
            Si = FactorPrecision(stStar, iP, 1./fvj, T);
        end
        piBeta = sum(logAvg(storePiBeta),1);
        finishedThirdReducedRun = 1;
        save(join( [checkpointdir, 'ckpt'] ) )
    end
    FtStar = mean(storeFtj,3);
    storePiFt = zeros(nFactors, Runs);
    muStar = StateObsModelStar*FtStar + xbtStar;
    residsStar = yt - muStar;
    r2Star = sum(residsStar.*residsStar,2);
    
    %% Reduced Run for Factors
    fprintf('Reduced run for Factor\n')
    
    for r = startRR:Runs
        fprintf('RR = %i\n', r)
        opg = storeObsPrecisiong(:,r);
        fvg = storeFactorVarg(:,r);
        
        storePiFt(:,r) = piFtStar(FtStar, yt, xbtStar, Astar, stStar,...
            opg, fvg, Identities, InfoCell);
        
        obsVariancej = kowUpdateObsVariances(residsStar, v0,r0,T);
        obsPrecisionj = 1./obsVariancej;
        storeObsPrecisionj(:,r) = obsPrecisionj;
        if identification == 2
            [fvj, ~]  = drawFactorVariance(FtStar, stStar, fvj, s0, d0);
            storeFactorVarj(:,r) = fvj;
        end
    end
    
    piFt = sum(logAvg(storePiFt));
    obsPrecisionStar = mean(storeObsPrecisionj,2);
    factorVarianceStar = mean(storeFactorVarj,2);
    piObsVariance = sum(logigampdf(1./obsPrecisionStar, .5.*(v0+T), .5.*(r0+r2Star)));
    piFactorVariance = sum(piOmegaStar(factorVarianceStar, stStar, FtStar, s0,d0));
    
    posteriors = [piFt, piBeta, piA , piST, piObsVariance, piFactorVariance]
    posteriorStar = sum(posteriors)
    
    
    
    LL = zeros(K,1);
    %%%%%%%%%%%%%
    for k = 1:K
        tempy = yt(k,:);
        tempobv = 1./obsPrecisionStar(k);
        [P, ~]= FactorPrecision(0, tempobv, 1/tempobv, T);
        S = P\eye(T);
        Slowerinv = chol(S,'lower')\eye(T);
        LL(k) = adjustedlogmvnpdf( ((Slowerinv*tempy') - Slowerinv*muStar(k,:)' )', Slowerinv);
    end
    LogLikelihood = sum(LL);
    
    priorST = sum(logmvnpdf(stStar, g0, G0));
    priorObsVariance = sum(logigampdf(1./obsPrecisionStar, .5.*v0, .5.*r0));
    priorFactorVar = sum(logigampdf(factorVarianceStar, .5.*s0, .5.*d0));
    
    
    betaprior = beta0.*ones(1,dimX);
    BetaPrior = (1/B0inv).*eye(dimX);
    priorBeta = zeros(K,1);
    
    for k = 1:K
        priorBeta(k) = logmvnpdf(VARstar(:,k)', betaprior, BetaPrior);
    end
    priorBeta = sum(priorBeta);
    
    priorAstar = Apriors(InfoCell, Astar, a0, A0inv);
    Fpriorstar = zeros(nFactors,1);
    
    %%%%%%%%%%%
    
    for j = 1:nFactors
        vv = factorVarianceStar(j);
        [iP, ss,~,w] =initCovar(stStar(j,:), 1);
        if w~=0
            iP = eye(length(stStar(j,:)));
        end
        Kprecision = FactorPrecision(ss, iP, 1/vv, T);
        Fpriorstar(j) = logmvnpdf(FtStar(j,:), zeros(1,T ), Kprecision\eye(T));
    end
    Fpriorstar=sum(Fpriorstar)
    
    priors = [priorBeta, Fpriorstar, priorST,priorObsVariance, priorFactorVar, sum(priorAstar)]
    priorStar = sum(priors)
    
    
    ml = (LogLikelihood+priorStar)-posteriorStar
    summary = [LogLikelihood; priors'; -posteriors']
    fprintf('Marginal Likelihood of Model: %.3f\n', ml)
    rmdir(checkpointdir, 's')
    
    fytheta = LogLikelihood + Fpriorstar - piFt;
    my = fytheta + sum([priorST,priorObsVariance, priorFactorVar, sum(priorAstar), priorBeta]) - sum([piBeta, piA , piST, piObsVariance, piFactorVariance])
else
    ml = 'nothing';
    summary =0;
%     rmdir(checkpointdir, 's')
end
fprintf('New Method Estimation\n')
end