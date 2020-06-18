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


B0inv = B0\eye(size(b0,1))
A0inv = 1/A0;
beta = repmat(b0,K,1);
b0 = repmat(b0, 1,K);

zt = yt;

obsVariance = ones(K,1);
obsPrecision = 1./obsVariance;
factorVariance = ones(nFactors,1);
currobsmod = setObsModel(zeros(K,levels), InfoCell);
currobsmod(1) = 1/sqrt(2);
stateTransitions = .5.*ones(size(g0,1), nFactors);
size(surX)
size(b0(:))
Xbeta = reshape(surX*b0(:), K,T);
Ft =initFt;

Runs = Sims-bn;
storeBeta = zeros(KP,Runs);
storeFt = zeros(nFactors, T, Runs);
storeSt = zeros(nFactors, lags, Runs);
storeOm = zeros(K, levels, Runs);
storeD = zeros(K,Runs);
storeLatentData = zeros(K,T,Runs);
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
        stateTransitions(n,:)= drawAR(stateTransitions(n,:), Ft(n,:), factorVariance(n), g0,G0);
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
    storeVARj = storeBeta;
    storeFtj = storeFt;
    storeStateTransitionsj = storeSt;
    stj = mean(storeSt,3);
    Ftj = mean(storeFt,3);
    obsPrecisionj = obsVariance;
    fvj = factorVariance;
    [iP, ~] =initCovar(stj, fvj);
    Si = FactorPrecision(stj, iP, 1./fvj, T);
    
    [storeMeans, storeVars] = ComputeMeansVars(yt, Xbeta, Ft, Astar, stateTransitions,...
        obsPrecision, factorVariance, Identities, InfoCell, a0, A0inv);
    %% Reduced Run 1
    for r = 1:Runs
        fprintf('RR = %i\n', r)
        tzt = storeLatentData(:,:,r);
        [VAR, Xbeta] = VAR_ParameterUpdate(tzt, Xt, obsPrecisionj,...
            Astar, stj, fvj, b0, B0inv, FtIndexMat, subsetIndices);
        storeVARj(:,r) = VAR(:);
        Ftg = storeFt(:,:,r);
        stg = storeStateTransitionsg(:,:,r);
        
        [~, Ftj, stoAlphag(:,r)] =  mvp_LoadFacGstep(tzt,Xbeta,Ftj, Astar, stj,...
            obsPrecisionj,fvj, Identities, InfoCell, a0, A0inv, storeMeans, storeVars);
        
        stoAlphaj(:,r) = mvp_LoadFacJstep(Astar, storeOm(:,:,r), ...
            tzt, Xbeta, Ftg, stg, obsPrecision, factorVariance, Identities,...
            InfoCell,  a0, A0inv, storeMeans, storeVars);
    end
    
    piA = sum(logAvg(stoAlphag) - logAvg(stoAlphaj));
    StateObsModelStar =  makeStateObsModel(Astar,Identities,0);
    stStar = mean(storeStateTransitionsg,3);
    storeFtg = storeFtj;
    storeStateTransitionsg = storeStateTransitionsj;
    Ftj = mean(storeFtg,3);
    obsPrecisionj = obsPrecision;
    fvj =factorVariance;
    stoAlphaj = zeros(nFactors, Runs);
    stoAlphag = zeros(nFactors, Runs);
    
    clear storeLatentData
    
    %% Reduced Run 2
    for r = 1:Runs
        fprintf('RR = %i\n', r)
        Af = Astar*Ftj;
        zt = mvp_latentDataDraw(zt,yt, Xbeta + Af, diag(obsVariance));
        
        for n = 1:nFactors
            [~,stoAlphaj(n,r)] = drawAR(stStar(n,:), Ftj(n,:), fvj(n), g0, G0);
        end
        alphag = drawSTAlphag(storeStateTransitionsg(:,:,r), stStar,...
            storeFtg(:,:,r), factorVariance, g0, G0);
        stoAlphag(:,r) = alphag;
        
        [VAR, Xbeta] = VAR_ParameterUpdate(zt, Xt, obsPrecisionj,...
            Astar, stStar, fvj, b0, B0inv, FtIndexMat, subsetIndices);
        storeVARj(:,r) = VAR(:);
        [iP, ~] =initCovar(stStar, fvj);
        Si = FactorPrecision(stStar, iP, 1./fvj, T);
        veczt = reshape(zt-Xbeta, K*T,1);
        Ftj = reshape(kowUpdateLatent(veczt, StateObsModelStar,...
            Si, obsPrecisionj), nFactors, T);
        storeFtj(:,:,r) = Ftj;
    end
    
    %% Reduced Run 3
    for r = 1:Runs
        fprintf('RR = %i\n', r)
        Af = Astar*Ftj;
        zt = mvp_latentDataDraw(zt,yt, Xbeta + Af, diag(obsVariance));
        
        
        for n = 1:nFactors
            [~,stoAlphaj(n,r)] = drawAR(stStar(n,:), Ftj(n,:), fvj(n), g0, G0);
        end
        alphag = drawSTAlphag(storeStateTransitionsg(:,:,r), stStar,...
            storeFtg(:,:,r), factorVariance, g0, G0);
        stoAlphag(:,r) = alphag;
        
        [VAR, Xbeta] = VAR_ParameterUpdate(tzt, Xt, obsPrecisionj,...
            Astar, stStar, fvj, b0, B0inv, FtIndexMat, subsetIndices);
        storeVARj(:,r) = VAR(:);
        [iP, ~] =initCovar(stStar, fvj);
        Si = FactorPrecision(stStar, iP, 1./fvj, T);
        veczt = reshape(tzt-Xbeta, K*T,1);
        Ftj = reshape(kowUpdateLatent(veczt, StateObsModelStar,...
            Si, obsPrecisionj), nFactors, T);
        storeFtj(:,:,r) = Ftj;
    end
    
    piST = sum(logAvg(stoAlphag) - logAvg(stoAlphaj));
    VARstar = reshape(mean(storeVARj,2), P, K);
    betaStar = reshape(VARstar, P*K,1);
    xbtStar = reshape(surX*betaStar,K,T);
    ydemutStar = tzt- xbtStar;
    storePiBeta = zeros(K,Runs);
    
    for r = 1:Runs
        fprintf('RR = %i\n', r)
        Af = Astar*Ftj;
        zt = mvp_latentDataDraw(zt,yt, xbtStar + Af, diag(obsVariance));
        
        storePiBeta(:,r) = piBetaStar(VARstar, zt, Xt, obsVariance,...
            Astar, stStar, fvj, b0, B0inv, subsetIndices, FtIndexMat);
        Ftj = reshape(kowUpdateLatent(ydemutStar(:), StateObsModelStar,...
            Si,  1), nFactors, T);
        storeFtj(:,:,r) = Ftj;
    end
    
    FtStar = mean(storeFtj,3);
    storePiFt = zeros(nFactors, Runs);
    Af = Astar*FtStar;
    for r = 1:Runs
        fprintf('RR = %i\n', r)
        zt = mvp_latentDataDraw(zt,yt, xbtStar + Af, diag(obsVariance));
        storePiFt(:,r) = piFtStar(FtStar, zt, xbtStar, Astar, stStar,...
            obsPrecisionj, fvj, Identities, InfoCell);
    end
    
    piBeta = sum(logAvg(storePiBeta),1);
    FtStar = mean(storeFtj,3);
    piFt = sum(logAvg(storePiFt));
    posteriors = [piFt, piBeta, piA , piST]
    posteriorStar = sum(posteriors)
    muStar = StateObsModelStar*FtStar + xbtStar;
    LogLikelihood = sum(ghk_integrate(yt, xbtStar, eye(K), 1000));

    
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

