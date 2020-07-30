function [storeBeta, storeFt, storeSt, storeOm,  ml, overview] = mvp_WithFactors(yt, Xt,...
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
lags = size(g0,2);
restrictions = restrictedElements(InfoCell);
restrictions = restrictions > 0;
zerorestrictions = (restrictions < 0);

zt = yt;
obsVariance = ones(K,1);
obsPrecision = 1./obsVariance;
factorVariance = ones(nFactors,1);
currobsmod = setObsModel(zeros(K,levels), InfoCell);
currobsmod(restrictions > 0 ) = 1/sqrt(2);
currobsmod(zerorestrictions) = 0;

d =diag(currobsmod*currobsmod' + eye(K));
Astate = diag(d.^(-.5))*currobsmod;

stateTransitions = .5.*ones(nFactors, lags);
Xbeta = reshape(surX*ones(size(surX,2),1), K,T);
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
ap=zeros(nFactors,1);

Astate = makeStateObsModel(currobsmod, Identities, 0);
Af = Astate*Ft;
for s = 1:Sims
    fprintf('Simulation %i\n', s)
    
    % Sample latent data
    zt = mvp_latentDataDraw(zt,yt, Xbeta + Af, diag(d));
    % Sample beta
    [beta, Xbeta] = VAR_ParameterUpdate(zt, Xt, 1./d,...
        currobsmod, stateTransitions, factorVariance, b0,...
        1/B0, FtIndexMat, subsetIndices);
    
    % Factors loadings
    [currobsmod, Ft,~,  acc]=...
        mvp_LoadFacUpdate(zt, Xbeta, Ft, currobsmod, stateTransitions,...
        1./d, factorVariance, Identities, InfoCell, a0, A0);
    ap = ap + acc;
    Astate = makeStateObsModel(currobsmod, Identities, 0);
    Af = Astate*Ft;
    d = diag(Astate*Astate' + eye(K)).^(-.5);
    % State transitions
    for n=1:nFactors
        [stateTransitions(n,:), ~, g1, G1] = drawAR(stateTransitions(n,:), Ft(n,:), 1, g0,G0);
    end
    
    % Store Posteriors
    if s > bn
        m = s-bn;
        storeBeta(:,m) = beta(:);
        storeFt(:,:,m) = Ft;
        storeSt(:,:,m) = stateTransitions;
        storeOm(:,:,m) = currobsmod;
        storeLatentData(:,:,m) = zt;
        g1bar = g1bar + g1;
        G1bar = G1bar + G1;
    end
    
end
acceptance_prob = ap ./ Sims

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
    
    [storeMeans, storeVars] = mvp_ComputeMeansVars(yt, Xbeta, Ft, Astar, stateTransitions,...
        obsPrecision, factorVariance, Identities, InfoCell, a0, A0);
    ztj = mean(storeLatentData,3);
    Xbetaj = reshape(surX*mean(storeBeta,2), K,T);
    Aj = mean(storeOm,3);
    
    %% Reduced Run 1
    fprintf('Reduced Run for loadings\n')
    for r = 1:Runs
        fprintf('RR = %i\n', r)
        Ag = storeOm(:,:,r);
        ztg = storeLatentData(:,:,r);
        Ftg = storeFt(:,:,r);
        stg = storeStateTransitionsg(:,:,r);
        betag = storeBeta(:,r);
        Xbetag = reshape(surX*betag, K,T);
        
        stoAlphag(:,r) = mvp_LoadFac_Gstep(Astar, Ag, ztg, Xbetag, Ftg, stg, 1./d, factorVariance, Identities,...
            InfoCell,  a0, A0, storeMeans, storeVars);
        
        [Aj, Ftj, stoAlphaj(:,r), ~] =  mvp_LoadFac_Jstep(ztg, Xbetag, Ftg, Astar, stg,...
            obsVariance,factorVariance, Identities, InfoCell, a0, A0, storeMeans, storeVars);
        Aj = makeStateObsModel(Aj, Identities, 0);
        d = diag(Aj*Aj' + eye(K)).^(-.5);
        Afj = Aj*Ftj;
        ztj = mvp_latentDataDraw(ztj,yt, Xbetaj + Afj, diag(d));
        [VAR, ~] = VAR_ParameterUpdate(ztj, Xt, 1./d,...
            Astar, stj, factorVariance, b0, 1/B0, FtIndexMat, subsetIndices);
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
             Astar = makeStateObsModel(Astar, Identities, 0);
        dstar = diag(Astar*Astar' + eye(K)).^(-.5);
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
        
        ztj= mvp_latentDataDraw(ztg,yt, Xbeta + Afg, diag(dstar));
        [VAR, Xbeta] = VAR_ParameterUpdate(ztg, Xt, 1./dstar,...
            Astar, stStar, fvj, b0, 1/B0, FtIndexMat, subsetIndices);
        [iP, ~] =initCovar(stStar, fvj);
        Si = FactorPrecision(stStar, iP, 1./fvj, T);
        veczt = reshape(ztg-Xbetag, K*T,1);
        Ftj = reshape(kowUpdateLatent(veczt, StateObsModelStar,...
            Si, 1./dstar), nFactors, T);
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
        storePiBeta(:,r) = piBetaStar(VARstar, ztg, Xt, 1./dstar,...
            Astar, stStar, fvj, b0, 1/B0, subsetIndices, FtIndexMat);
        
        ztj = mvp_latentDataDraw(ztg,yt, xbtStar + Afg, diag(dstar));
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
            1./dstar, fvj, Identities, InfoCell);
    end
    piFt = sum(logAvg(storePiFt));
    
    
    muStar = StateObsModelStar*FtStar + xbtStar;
    LogLikelihood = sum(ghk_integrate(yt, muStar, diag(dstar), 1000))
    posteriors = [piFt, piBeta, piA , piST]
    posteriorStar = sum(posteriors)
    
    priorST = sum(logmvnpdf(stStar, g0, G0));
    B=B0.*eye(P*K);
    priorBeta = logmvnpdf(betaStar', b0.*ones(1,P*K), B);
    priorAstar = Apriors(InfoCell, Astar, a0, A0);
    
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
    overview = table({'LogLikelihood', 'Fpriorstar', 'priorST', 'priorAstar', 'priorBeta', 'piFt', 'piBeta', 'piA' , 'piST'}', [LogLikelihood, priors, -posteriors]');
    
    
else
    ml=0;
    overview=0;
end
end

