function [storeBeta, storeFt, storeSt, storeOm, storeD, ml] = mvp_WithFactors(yt, Xt,...
    Sims,bn, InfoCell, b0, B0,g0, G0, a0, A0, initFt, estml)
[K,T]=size(yt);
[~,P]=size(Xt);
KT =K*T;
KP = K*P;
IKP = eye(KP);
surX = surForm(Xt,K);
subsetIndices=reshape(1:KT, K,T);
IK = eye(K);
ZeroK = zeros(1,K);

FtIndexMat = CreateFactorIndexMat(InfoCell);
levels = size(InfoCell,2);
nFactors = sum(cellfun(@(x)size(x,1), InfoCell));
[Identities, ~, ~] = MakeObsModelIdentity( InfoCell);
lags = size(g0,1);

b0 = ones(P,1).*b0;
b0 = repmat(b0, 1,K);
B0inv = B0\eye(size(b0,1));
A0inv = 1/A0;
beta = repmat(b0,K,1);

zt = yt;
obsVariance = ones(K,1);
obsPrecision = 1./obsVariance;
factorVariance = ones(nFactors,1);
currobsmod = setObsModel(zeros(K,levels), InfoCell);
currobsmod(1) = 1/sqrt(2);
stateTransitions = .5.*ones(size(g0,1), nFactors);
Xbeta = reshape(surX*b0(:), K,T);
Ft =initFt;

Runs = Sims-bn;
storeBeta = zeros(KP,Runs);
storeFt = zeros(nFactors, T, Runs);
storeSt = zeros(nFactors, lags, Runs);
storeOm = zeros(K, levels, Runs);
storeD = zeros(K,Runs);
storeLatentData = zeros(K,T,Runs);
g1bar = zeros(1,lags);
G1bar = zeros(lags);


for s = 1:Sims
    fprintf('Simulation %i\n', s)
    Astate = makeStateObsModel(currobsmod, Identities, 0);
    Af = Astate*Ft;
    % Sample latent data
    zt = mvp_latentDataDraw(zt,yt, Xbeta + Af, diag(obsVariance));
    
    % Sample beta
    [beta, Xbeta] = VAR_ParameterUpdate(zt, Xt, obsPrecision,...
        currobsmod, stateTransitions, factorVariance, b0,...
        B0inv, FtIndexMat, subsetIndices);
    
    % Factors loadings
    [currobsmod, Ft,~, d]=...
        mvp_LoadFacUpdate(zt, Xbeta, Ft, currobsmod, stateTransitions,...
        obsPrecision, factorVariance, Identities, InfoCell, a0, A0inv);
    
    % State transitions
    for n=1:nFactors
        [stateTransitions(n,:), ~, g1, G1] = drawAR(stateTransitions(n,:), Ft(n,:), factorVariance(n), g0,G0);
    end
    
    % Store Posteriors
    if s > bn
        m = s-bn;
        storeBeta(:,m) = beta(:);
        storeFt(:,:,m) = Ft;
        storeSt(:,:,m) = stateTransitions;
        storeOm(:,:,m) = currobsmod;
        storeD(:,m) = d;
        storeLatentData(:,:,m) = zt;
        g1bar = g1bar + g1;
        G1bar = G1bar + G1;
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
% Marginal Likelihood
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
if estml == 1
    Astar = mean(storeOm,3);
    stoAlphaj = zeros(nFactors, Runs);
    stoAlphag = zeros(nFactors, Runs);
    storeStateTransitionsg = storeSt;
    storeBetaj = storeBeta;
    storeFtj = storeFt;
    storeStateTransitionsj = storeSt;
    storeLatentDataj = storeLatentData;
    stj = mean(storeSt,3);
    fvj = factorVariance;
    [iP, ~] =initCovar(stj, fvj);
    Si = FactorPrecision(stj, iP, 1./fvj, T);
    g1bar = g1bar./Runs;
    G1bar = G1bar./Runs;
    
    [storeMeans, storeVars] = ComputeMeansVars(yt, Xbeta, Ft, Astar, stateTransitions,...
        obsPrecision, factorVariance, Identities, InfoCell, a0, A0inv);
    ztj = mean(storeLatentData,3);
    Xbetaj = reshape(surX*mean(storeBeta,2), K,T);
    Aj = mean(storeOm,3);
    
    %% Reduced Run 1
    fprintf('Reduced Run for loadings\n')
    for r = 1:Runs
        fprintf('RR = %i\n', r)
        ztg = storeLatentData(:,:,r);
        Ftg = storeFt(:,:,r);
        stg = storeStateTransitionsg(:,:,r);
        betag = storeBeta(:,r);
        Xbetag = reshape(surX*betag, K,T);
        [~, Ftj, stoAlphag(:,r)] =  mvp_LoadFacGstep(ztg, Xbetag, Ftg, Astar, stg,...
            obsVariance,factorVariance, Identities, InfoCell, a0, A0inv, storeMeans, storeVars);
        
        Afj = Astate*Ftj;
        stoAlphaj(:,r) = mvp_LoadFacJstep(Astar, Aj, ...
            ztj, Xbetaj, Ftj, stj, obsPrecision, factorVariance, Identities,...
            InfoCell,  a0, A0inv, storeMeans, storeVars);
        ztj = mvp_latentDataDraw(ztj,yt, Xbetaj + Afj, diag(obsVariance));
        [VAR, ~] = VAR_ParameterUpdate(ztj, Xt, obsVariance,...
            Astar, stj, factorVariance, b0, B0inv, FtIndexMat, subsetIndices);
        % State transitions
        for n=1:nFactors
            [storeStateTransitionsj(n,:), ~, ~, ~] = drawAR(stj(n,:), Ftj(n,:), factorVariance(n), g0,G0);
        end
        storeBetaj(:,r) = VAR(:);
        storeFtj(:,:,r) = Ftj;
        storeLatentDataj(:,:,r) = ztj;
    end
    
    piA = sum(logAvg(stoAlphag) - logAvg(stoAlphaj));
    StateObsModelStar =  makeStateObsModel(Astar,Identities,0);
    stStar = mean(storeStateTransitionsg,3);
    storeStateTransitionsg = storeStateTransitionsj;
    obsPrecisionj = obsPrecision;
    fvj =factorVariance;
    stoAlphaj = zeros(nFactors, Runs);
    stoAlphag = zeros(nFactors, Runs);
    
    storeBetag = storeBetaj;
    storeFtg = storeFtj;
    storeLatentDatag= storeLatentDataj;
    %% Reduced Run 2
    for r = 1:Runs
        fprintf('RR = %i\n', r)
        ztg = storeLatentDatag(:,:,r);
        Ftg = storeFtg(:,:,r);
        betag = storeBetag(:,r);
        Afg = Astar*Ftg;
        Xbetag = reshape(surX*betag, K,T);
        for n = 1:nFactors
            [stoAlphaj(n,r)] = drawAR_Jstep(stStar(n,:), Ftg(n,:), fvj(n), g0, G0, g1bar, G1bar);
        end
        alphag = drawSTAlpha_Gstep(storeStateTransitionsg(:,:,r), stStar,...
            storeFtg(:,:,r), factorVariance, g0, G0);
        stoAlphag(:,r) = alphag;

        ztj= mvp_latentDataDraw(ztg,yt, Xbeta + Afg, diag(obsVariance));
        [VAR, Xbeta] = VAR_ParameterUpdate(ztg, Xt, obsPrecisionj,...
            Astar, stStar, fvj, b0, B0inv, FtIndexMat, subsetIndices);
        [iP, ~] =initCovar(stStar, fvj);
        Si = FactorPrecision(stStar, iP, 1./fvj, T);
        veczt = reshape(ztg-Xbetag, K*T,1);
        Ftj = reshape(kowUpdateLatent(veczt, StateObsModelStar,...
            Si, obsPrecisionj), nFactors, T);
        storeLatentDataj(:,:,r) = ztj;
        storeBetaj(:,r) = VAR(:);
        storeFtj(:,:,r) = Ftj;
    end
    piST = sum(logAvg(stoAlphag) - logAvg(stoAlphaj));
    storeLatentDatag = storeLatentDataj;
    storeFtg = storeFtj;
    
    VARstar = reshape(mean(storeBetaj,2), P, K);
    betaStar = reshape(VARstar, P*K,1);
    xbtStar = reshape(surX*betaStar,K,T);
    storePiBeta = zeros(K,Runs);
    
    for r = 1:Runs
        fprintf('RR = %i\n', r)
        ztg = storeLatentDatag(:,:,r);
        Ftg = storeFtg(:,:,r);
        Afg = Astar*Ftg;
        storePiBeta(:,r) = piBetaStar(VARstar, ztg, Xt, obsVariance,...
            Astar, stStar, fvj, b0, B0inv, subsetIndices, FtIndexMat);
        
        ztj = mvp_latentDataDraw(ztg,yt, xbtStar + Afg, diag(obsVariance));
        ztdemut = ztg - xbtStar;
        Ftj = reshape(kowUpdateLatent(ztdemut(:), StateObsModelStar,...
            Si,  1), nFactors, T);
        storeFtj(:,:,r) = Ftj;
        storeLatentDataj(:,:,r) = ztj;
    end
    piBeta = sum(logAvg(storePiBeta),1);
    
    FtStar = mean(storeFtj,3);
    storePiFt = zeros(nFactors, Runs);
    for r = 1:Runs
        fprintf('RR = %i\n', r)
        ztg = storeLatentDatag(:,:,r);
        storePiFt(:,r) = piFtStar(FtStar, ztg, xbtStar, Astar, stStar,...
            obsPrecisionj, fvj, Identities, InfoCell);
    end
    piFt = sum(logAvg(storePiFt));
    
    
    muStar = StateObsModelStar*FtStar + xbtStar;
    LogLikelihood = sum(ghk_integrate(yt, muStar, eye(K), 1000))
    posteriors = [piFt, piBeta, piA , piST]
    posteriorStar = sum(posteriors)
    
    priorST = sum(logmvnpdf(stStar, g0, G0));
    B0inv=diag(repmat(1./diag(B0inv), K,1));
    
    priorBeta = logmvnpdf(betaStar', b0(:)', B0inv);
    priorAstar = Apriors(InfoCell, Astar, a0, A0inv);
    
    Fpriorstar = zeros(nFactors,1);
    for j = 1:nFactors
        [iP, ~] =initCovar(stStar(j,:), factorVariance(j));
        Kprecision = FactorPrecision(stStar(j,:), iP, 1, T);
        Fpriorstar(j) = logmvnpdf(FtStar(j,:), zeros(1,T ), Kprecision\eye(T));
    end
    Fpriorstar=sum(Fpriorstar);
    priors = [Fpriorstar, priorST, sum(priorAstar), priorBeta]
    priorStar = sum(priors)
    ml = (LogLikelihood+priorStar)-posteriorStar
    
else
    ml=0;
end
end

