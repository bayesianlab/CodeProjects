function [storeMeans, storeLoadings, storeOmArTerms,...
    storeStateArTerms, storeFt, storeObsV, storeFactorVariance,...
    varianceDecomp, ML, vd, Summary] = Baseline(InfoCell,yt, xt, Ft, MeansLoadings,  omArTerms,...
    factorArTerms, b0,B0inv, v0,d0, s0, r0, g0,G0, Sims, burnin, autoRegressiveErrors, calcML)
%% Definitions
% yt comes in as
%[ y11...y1T;
% ...
% yK1...yKT'

% xt comes in as
%[1 x11;
%...
% 1 x1K;
% ...
% 1 xT1;
% ...
% 1 xTK]

% MeansLoadings comes in as
% [mu1...muK;
% Load1...LoadK]

% omArTerms comes in as  (p lags)
% [delta1p ... delta11;
% ...
% deltaKp ... deltaK1]

% gammas comes in as deltas.
%% Setup and indices

[K,T] = size(yt);
[KT, nObservablesCols]= size(xt);
[nFactors,  lagState] = size(factorArTerms);
meanRange = 1:nObservablesCols;
levels=length(InfoCell);
[~,M] =size(MeansLoadings);
factorRange  = (nObservablesCols+1):M;
allLevels = 1:levels;

[~, lagOm] = size(omArTerms);
[~, lagState]= size(factorArTerms);
[Identities,~,~]=MakeObsModelIdentity(InfoCell);
restrictions = restrictedElements(InfoCell);
FtIndexMat = CreateFactorIndexMat(InfoCell);
subsetIndices = zeros(K,T);

for k = 1:K
    subsetIndices(k,:)= k:K:KT;
end
lagind = 1:lagOm;
IT = eye(T);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);

%% Posterior Storage
Runs = Sims-burnin;
storeMeans = zeros(K,nObservablesCols, Runs);
storeLoadings = zeros(K, levels, Runs);
storeOmArTerms = zeros(K, lagOm,Runs);
storeStateArTerms = zeros(nFactors, lagState,Runs);
storeFt = zeros(nFactors, T, Runs);
storeObsV = zeros(K,Runs);
storeFactorVariance = zeros(nFactors,Runs);
%% Initializations
igParamA = .5.*(v0 + T);
obsVariance = ones(K,1);
factorVariance = ones(nFactors,1);
dimx = nObservablesCols + levels;
beta = zeros(dimx,K);
meanFunction = MeansLoadings(:,meanRange)';
loadings = MeansLoadings(:, factorRange);
fakeX = zeros(T,1);
fakeB = zeros(1,1);
if autoRegressiveErrors == 0
    omArTerms=zeros(K,lagOm);
end


for i = 1:Sims
    fprintf('Simulation i = %i\n',i)
    
    %% Draw Mean, Loadings and AR Parameters
    for k = 1:K
        tempI = subsetIndices(k,:);
        tempy = yt(k,:);
        tempx=[xt(tempI,:),Ft(FtIndexMat(k,:),:)'];
        tempobv = obsVariance(k);
        if autoRegressiveErrors == 1
            tempdel=omArTerms(k,:);
            [tempD0,~,~,w] = initCovar(tempdel, tempobv);
            if w ~=0
                tempD0 = eye(length(tempdel));
            end
        else
            tempdel = 0;
            tempD0 = tempobv;
        end
        [beta(:,k), ~,~,~,~, ~] = drawBeta(tempy, tempx,  tempdel, tempobv, tempD0, b0, B0inv);
        loadings(k,:) = beta(factorRange,k);
        loadings(k,:) = (loadings(k,:) + restrictions(k,:)) - (loadings(k,:).*double(restrictions(k,:) > 0));
        beta(factorRange,k) = loadings(k,:)';
        if autoRegressiveErrors == 1
            epsi = tempy - reshape(tempx*beta(:,k),1,T);
            omArTerms(k,:)= drawAR(tempdel,epsi, tempobv, g0,G0);
        end
        [~, H]= FactorPrecision(tempdel, tempD0, 1/tempobv, T);
        igParamB=.5.*(d0+sum( ( (H*tempy') -  (H*( tempx*beta(:,k) ) ) ).^2));
        obsVariance(k) = 1./gamrnd(igParamA, 1./igParamB);
    end
    meanFunction= beta(meanRange,:);
    
    %% Draw Factors
    SurX = surForm(xt,K);
    mu1t = reshape(SurX*meanFunction(:),K,T);
    demuyt = yt - mu1t;
    c=0;
    sorder = 1:levels;
    
    for q = sorder
        Info = InfoCell{1,q};
        COM = makeStateObsModel(loadings, Identities, q);
        alpha =loadings(:,q);
        tempyt = demuyt - COM*Ft;
        for w = 1:size(Info,1)
            % Factor level
            c=c+1;
            subsI = Info(w,1):Info(w,2);
            commonPrecisionComponent = zeros(T,T);
            commonMeanComponent = zeros(T,1);
            if autoRegressiveErrors == 1
                for k = subsI
                    % Equation level
                    ty = tempyt(k,:);
                    [D0, ssOmArTerms,~,nv] = initCovar(omArTerms(k,:), obsVariance(k));
                    if nv~=0
                        D0 = eye(length(omArTerms(k,:)));
                    end
                    [CV, ~] = FactorPrecision(ssOmArTerms, D0, 1./obsVariance(k), T);
                    commonMeanComponent = commonMeanComponent + alpha(k)*CV*ty(:);
                    commonPrecisionComponent = commonPrecisionComponent + (alpha(k)^2)*CV;
                end
            else
                for k = subsI
                    % Equation level
                    ty = tempyt(k,:);
                    QQsigma = IT* (1./obsVariance(k));
                    commonMeanComponent = commonMeanComponent + alpha(k)*QQsigma*ty(:);
                    commonPrecisionComponent = commonPrecisionComponent + (alpha(k)^2)*QQsigma;
                end
            end
            [L0, ssGammas,~,nv] = initCovar(factorArTerms(c,:), factorVariance(c));
            if nv~=0
                L0 = eye(length(factorArTerms(c,:)));
            end
            [CV,~] = FactorPrecision(ssGammas, L0, 1./factorVariance(c), T);
            OmegaInv = (commonPrecisionComponent +CV);
            Linv = chol(OmegaInv,'lower')\IT;
            Omega= Linv'*Linv;
            omega = Omega*commonMeanComponent;
            Ft(c,:) = (omega + Linv' * normrnd(0,1,T,1))';
        end
    end
    
    
    %% Draw Factor AR Parameters
    
    for n=1:nFactors
        factorArTerms(n,:)= drawAR(factorArTerms(n,:),Ft(n,:), factorVariance(n), g0,G0);
    end
    
    %% Draw Factor Variances
    [factorVariance,~]  = drawFactorVariance(Ft, factorArTerms, factorVariance, s0, r0);
    %% Store post burn-in runs
    if i > burnin
        v = i - burnin;
        storeMeans(:,:,v)=beta(meanRange,:)';
        storeLoadings(:,:,v) = loadings;
        storeOmArTerms(:, :,v) = omArTerms;
        storeStateArTerms(:,:,v) = factorArTerms;
        storeFt(:,:,v) = Ft;
        storeObsV(:,v) = obsVariance;
        storeFactorVariance(:,v) = factorVariance;
    end
    
end



%% Variance decomposition
om = mean(storeLoadings,3);
beta = mean(storeMeans,3);
Ft = mean(storeFt,3);
mu1 = reshape(surForm(xt,K)*beta(:),K,T);
if autoRegressiveErrors == 1
    vd_eps = levels+2;
    vd = zeros(K,vd_eps);
    omAr = mean(storeOmArTerms,3);
    S = makeStateObsModel(om, Identities,0);
    mu2 = S*Ft;
    resids = yt - mu1 - mu2;
    mu1 = reshape(surForm(xt,K)*beta(:),K,T);
    vd(:,1) = var(mu1, [], 2);
    for k = 1:K
        epslag = lagMat(resids(k,:), lagOm)';
        vd(k, vd_eps)=var(epslag*omAr(k,:)');
        for j = 1:levels
            tempF = Ft(FtIndexMat(k,j),:);
            vd(k,j+1)=var(tempF*om(k,j));
        end
    end
    
    varianceDecomp = vd./sum(vd,2);
    mean(varianceDecomp)
else
    vd = zeros(K,levels+1);
    mu1 = reshape(surForm(xt,K)*beta(:),K,T);
    vd(:,1) = var(mu1, [], 2);
    for k = 1:K
        for j = 1:levels
            tempF = Ft(FtIndexMat(k,j),:);
            vd(k,j+1)=var(tempF*om(k,j));
        end
    end
    varianceDecomp = vd./sum(vd,2);
end

if calcML == 1
    %% Marginal likelihood
    ReducedRuns = Sims-burnin;
    betaStar = mean([storeMeans, storeLoadings],3)';
    storePiBeta = zeros(K,ReducedRuns);
    storeFtj = zeros(nFactors, T,ReducedRuns);
    storeOmArj = storeOmArTerms;
    storeStateArj = storeStateArTerms;
    storeObsVj  = storeObsV;
    storeFactorVariancej = storeFactorVariance;
    factorArTermsj = factorArTerms;
    omArTermsj = omArTerms;
    Ftj = mean(storeFt,3);
    
    ovj = mean(storeObsV,2);
    factorVariancej = mean(storeFactorVariance,2);
    %% Reduced run for betas
    fprintf('Beta RR\n')
    for rr = 1:ReducedRuns
        fprintf('RR = %i\n', rr)
        
        Ftg = storeFt(:,:,rr);
        omarg = storeOmArTerms(:,:,rr);
        ovg = storeObsV(:,rr);
        for k = 1:K
            tempI = subsetIndices(k,:);
            tempy = yt(k,:);
            tempx=[xt(tempI,:),Ftg(FtIndexMat(k,:),:)'];
            tempobv = ovg(k);
            if autoRegressiveErrors == 1
                tempdel=omarg(k,:);
                [tempD0,~,~,nv] = initCovar(tempdel, tempobv);
                if nv ~=0
                    tempD0 = eye(length(tempdel));
                end
            else
                tempdel = 0;
                tempD0 = tempobv;
            end
            
            [storePiBeta(k,rr), ~, ~, ~] = drawBetaML(betaStar(:,k), tempy, tempx,  tempdel,...
                tempobv, tempD0, b0, B0inv);
            
            tempdel=omArTermsj(k,:);
            tempobv = ovj(k);
            [tempD0,~,~,nv] = initCovar(tempdel, tempobv);
            if nv ~= 0
                tempD0 = eye(length(tempdel));
            end
            [~, H]= FactorPrecision(tempdel, tempD0, 1/tempobv, T);
            loadings(k,:) = betaStar(factorRange,k);
            loadings(k,:) = (loadings(k,:) + restrictions(k,:)) - (loadings(k,:).*double(restrictions(k,:) > 0));
            if autoRegressiveErrors == 1
                epsi = tempy - reshape(tempx*betaStar(:,k),1,T);
                omArTermsj(k,:)= drawAR(tempdel,epsi, tempobv, g0,G0);
            end
            igParamB=.5.*(d0+sum( ( (H*tempy') -  (H*(tempx*betaStar(:,k)) ) ).^2));
            ovj(k) = 1./gamrnd(igParamA, 1./igParamB);
        end
        % Draw Factors
        SurX = surForm(xt,K);
        mu1t = reshape(SurX*meanFunction(:),K,T);
        demuyt = yt - mu1t;
        c=0;
        for q = 1:levels
            Info = InfoCell{1,q};
            COM = makeStateObsModel(loadings, Identities, q);
            alpha =loadings(:,q);
            tempyt = demuyt - COM*Ftj;
            for w = 1:size(Info,1)
                % Factor level
                c=c+1;
                fvcj = factorVariancej(c);
                farcj = factorArTermsj(c,:);
                subsI = Info(w,1):Info(w,2);
                commonPrecisionComponent = zeros(T,T);
                commonMeanComponent = zeros(T,1);
                if autoRegressiveErrors == 1
                    for k = subsI
                        % Equation level
                        ty = tempyt(k,:);
                        ovkj = ovj(k);
                        [D0, ssOmArTerms,~,nv] = initCovar(omArTermsj(k,:), ovkj);
                        if nv ~= 0
                            D0 = eye(length(omArTermsj(k,:)));
                        end
                        [CV, ~] = FactorPrecision(ssOmArTerms, D0, 1./ovkj, T);
                        commonMeanComponent = commonMeanComponent + alpha(k)*CV*ty(:);
                        commonPrecisionComponent = commonPrecisionComponent + (alpha(k)^2)*CV;
                    end
                else
                    for k = subsI
                        % Equation level
                        ty = tempyt(k,:);
                        QQsigma = IT* (1./obsVariance(k));
                        commonMeanComponent = commonMeanComponent + alpha(k)*QQsigma*ty(:);
                        commonPrecisionComponent = commonPrecisionComponent + (alpha(k)^2)*QQsigma;
                    end
                end
                [L0, ssGammas,~,nv] = initCovar(farcj, fvcj);
                if nv~=0
                    L0 = eye(length(farcj));
                end
                StatePrecision = FactorPrecision(ssGammas, L0, 1./fvcj, T);
                OmegaInv = commonPrecisionComponent + StatePrecision;
                Linv = chol(OmegaInv,'lower')\IT;
                Omega= Linv'*Linv;
                omega =Omega*commonMeanComponent;
                Ftj(c,:) = omega + Linv' * normrnd(0,1,T,1);
            end
        end
        storeFtj(:,:, rr) = Ftj;
        
        % Draw Factor AR Parameters
        for n=1:nFactors
            factorArTermsj(n,:)= drawAR(factorArTerms(n,:),Ft(n,:), factorVariance(n), g0,G0);
        end
        
        % Draw Factor Variances
        [factorVariancej, ~]  = drawFactorVariance(Ftj, factorArTermsj, factorVariancej, s0, r0);
        %% Store post burn-in runs
        storeOmArj(:, :,rr) = omArTermsj;
        storeStateArj(:,:,rr) = factorArTermsj;
        storeFtj(:,:,rr) = Ftj;
        storeObsVj(:,v) = ovj;
        storeFactorVariancej(:,v) = factorVariancej;
    end
    piBeta = sum(logAvg(storePiBeta));
    
    %%%%%%%%%%%%%%%%
    %% Reudced Runs for Factors
    fprintf('Factor RR\n')
    FactorStar = mean(storeFtj,3);
    storePiFactor = zeros(nFactors,ReducedRuns);
    storeOmArg = storeOmArj;
    storeObsVg = storeObsVj;
    storeStateArg = storeStateArj;
    storeFactorVarianceg = storeFactorVariancej;
    
    SurX = surForm(xt,K);
    mu1t = reshape(SurX*meanFunction(:),K,T);
    demuyt = yt - mu1t;
    
    for rr = 1:ReducedRuns
        fprintf('RR = %i\n', rr)
        omarg = storeOmArg(:,:,rr);
        ovg = storeObsVg(:,rr);
        for k = 1:K
            tempI = subsetIndices(k,:);
            tempy = yt(k,:);
            tempx=[xt(tempI,:),FactorStar(FtIndexMat(k,:),:)'];
            tempobv = ovg(k);
            
            if autoRegressiveErrors == 1
                tempdel=omarg(k,:);
                [tempD0,~,~,nv] = initCovar(tempdel, tempobv);
                if nv ~=0
                    tempD0 = eye(length(tempdel));
                end
            else
                tempdel = 0;
                tempD0 = tempobv;
            end
            [~, H]= FactorPrecision(tempdel, tempD0, 1/tempobv, T);
            igParamB=.5.*(d0+sum( ( (H*tempy') -  (H*(tempx*betaStar(:,k) ) ) ).^2));
            loadings(k,:) = betaStar(factorRange,k);
            loadings(k,:) = (loadings(k,:) + restrictions(k,:)) - (loadings(k,:).*double(restrictions(k,:) > 0));
            if autoRegressiveErrors == 1
                epsi = tempy - reshape(tempx*betaStar(:,k),1,T);
                omArTermsj(k,:)= drawAR(tempdel,epsi, tempobv, g0,G0);
            end
            ovj(k) = 1./gamrnd(igParamA, 1./igParamB);
        end
        % Draw Factors
        
        c=0;
        for q = 1:levels
            Info = InfoCell{1,q};
            COM = makeStateObsModel(loadings, Identities, q);
            alpha =loadings(:,q);
            tempyt = demuyt - COM*FactorStar;
            for w = 1:size(Info,1)
                % Factor level
                c=c+1;
                fvcg = storeFactorVarianceg(c,rr);
                farcg = storeStateArg(c,:, rr);
                subsI = Info(w,1):Info(w,2);
                commonPrecisionComponent = zeros(T,T);
                commonMeanComponent = zeros(T,1);
                if autoRegressiveErrors == 1
                    for k = subsI
                        % Equation level
                        ty = tempyt(k,:);
                        ovkg = ovg(k);
                        [D0, ssOmArTerms,~,nv] = initCovar(omArTermsj(k,:), ovkg);
                        if nv ~=0
                            D0 = eye(length(omArTermsj(k,:)));
                        end
                        [CV, ~] = FactorPrecision(ssOmArTerms, D0, 1./ovkg, T);
                        commonMeanComponent = commonMeanComponent + alpha(k)*CV*ty(:);
                        commonPrecisionComponent = commonPrecisionComponent + (alpha(k)^2)*CV;
                    end
                else
                    for k = subsI
                        % Equation level
                        ty = tempyt(k,:);
                        QQsigma = IT* (1./(ovg(k)));
                        commonMeanComponent = commonMeanComponent + alpha(k)*QQsigma*ty(:);
                        commonPrecisionComponent = commonPrecisionComponent + (alpha(k)^2)*QQsigma;
                    end
                end
                [L0, ssGammas,~,nv] = initCovar(farcg, fvcg);
                if nv ~= 0
                    L0 = eye(length(farcg));
                end
                StatePrecision = FactorPrecision(ssGammas, L0, 1./fvcg, T);
                Omega = (commonPrecisionComponent + StatePrecision)\IT;
                omega =Omega*commonMeanComponent;
                storePiFactor(c,rr)=logmvnpdf(FactorStar(c,:), omega', Omega);
            end
        end
        %% Draw Factor AR Parameters
        for n=1:nFactors
            factorArTermsj(n,:)= drawAR(factorArTermsj(n,:),FactorStar(n,:), factorVariancej(n), g0,G0);
        end
        storeStateArj(:,:, rr) = factorArTermsj;
        %% Draw Factor Variances
        [factorVariancej, ~]  = drawFactorVariance(FactorStar, factorArTermsj, factorVariancej, s0, r0);
        storeOmArj(:, :,rr) = omArTermsj;
        storeStateArj(:,:,rr) = factorArTermsj;
        storeObsVj(:,v) = ovj;
        storeFactorVariancej(:,v) = factorVariancej;
    end
    piFactor =sum(logAvg(storePiFactor));
    
    %%%%%%%%%%%%%%%%%%%%
    %% OM AR Reduced Run
    fprintf('O.M. AR/Factor AR RR\n')
    if autoRegressiveErrors == 1
        omARStar = mean(storeOmArj,3);
        omARStar = vetARStar(omARStar, yt, xt, FactorStar, betaStar,...
            obsVariance, g0, G0, subsetIndices, FtIndexMat);
    else
        omARStar = zeros(K,lagOm);
    end
    factorARStar = mean(storeStateArj,3);
    storeAlphaOMARj = zeros(K,  ReducedRuns);
    storeAlphaFactorj = zeros(K, ReducedRuns);
    quantOMARg = zeros(K,ReducedRuns);
    quantFactorg = zeros(K,ReducedRuns);
    
    storeStateArg = storeStateArj;
    storeFactorVarianceg = storeFactorVariancej;
    for rr = 1:ReducedRuns
        fprintf('RR = %i\n', rr)
        omarg = storeOmArg(:,:,rr);
        ovg = storeObsVg(:,rr);
        farg = storeStateArg(:,:, rr);
        factorVarianceg=storeFactorVarianceg;
        for k = 1:K
            tempI = subsetIndices(k,:);
            tempy = yt(k,:);
            tempx=[xt(tempI,:),FactorStar(FtIndexMat(k,:),:)'];
            tempobv = ovg(k);
            if autoRegressiveErrors == 1
                tempdelg=omarg(k,:);
                delgstar = omARStar(k,:);
                [tempD0star,~,~,w] = initCovar(delgstar, tempobv);
                if w ~=0
                    tempD0star = eye(length(tempdel));
                end
            else
                tempdelg = 0;
                delgstar = 0;
                tempD0star = tempobv;
            end
            [~, H]= FactorPrecision(delgstar, tempD0star, 1/tempobv, T);
            igParamB=.5.*(d0+sum( ( (H*tempy') -  (H*(tempx*betaStar(:,k) ) ) ).^2));
            if autoRegressiveErrors == 1
                quantOMARg(k,rr) = drawPhiG(delgstar,tempy, tempx,...
                    betaStar(:,k), tempdelg, tempobv, g0,G0);
                
                [ storeAlphaOMARj(k,rr)]  = drawPhiJ(tempy, tempx, betaStar(:,k),...
                    delgstar, tempobv, g0,G0);
                ovj(k) = 1./gamrnd(igParamA, 1./igParamB);
            end
        end
        %% Draw Factor AR Parameters
        for n=1:nFactors
            [ storeAlphaFactorj(n, rr)] = drawPhiJ(FactorStar(n,:), fakeX, fakeB, factorARStar(n,:),...
                factorVarianceg(n), g0, G0);
            quantFactorg(k,rr)=drawPhiG(factorARStar(n,:), FactorStar(n,:), fakeX, fakeB,...
                farg(n,:), factorVarianceg(n),g0,G0);
        end
        %% Draw Factor Variances
        [factorVariancej, ~]  = drawFactorVariance(FactorStar, factorARStar, factorVariancej,...
            s0, r0);
        
        storeFactorVariancej(:,rr) = factorVariancej;
        storeObsVj(:,rr) = ovj;
    end
    if autoRegressiveErrors== 1
        piOMAR = sum(logAvg(quantOMARg) - logAvg(storeAlphaOMARj));
    end
    piFactorAR = sum(logAvg(quantFactorg)-logAvg(storeAlphaFactorj));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Last RR
    omVarStar = mean(storeObsVj,2);
    factorVarStar = mean(storeFactorVariancej,2);
    piOmVar = zeros(K,1);
    for k = 1:K
        tempI = subsetIndices(k,:);
        tempy = yt(k,:);
        tempx=[xt(tempI,:),FactorStar(FtIndexMat(k,:),:)'];
        tempobv = omVarStar(k);
        if autoRegressiveErrors == 1
            tempdelg=omARStar(k,:);
            [tempD0g,~,~,nv] = initCovar(tempdelg, tempobv);
            if nv~=0
                tempD0g = eye(length(tempdelg));
            end
        else
            tempdelg = zeros(1,lagOm);
            tempD0g = tempobv;
        end
        [~, H]= FactorPrecision(tempdelg, tempD0g, 1/tempobv, T);
        igParamB=.5.*(d0+sum( ( (H*tempy') -  (H*(tempx*betaStar(:,k)) ) ).^2));
        piOmVar(k) = logigampdf(omVarStar(k), igParamA, igParamB);
    end
    piOmVar = sum(piOmVar);
    piFV = sum(piFactorVar(factorVarStar, FactorStar, factorARStar, factorVarStar, s0,r0));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Log likelihood
    
    
    LL = zeros(K,1);
    %%%%%%%%%%%%
    for k = 1:K
        tempI = subsetIndices(k,:);
        tempy = yt(k,:);
        tempx=[xt(tempI,:),FactorStar(FtIndexMat(k,:),:)'];
        tempobv = omVarStar(k);
        if autoRegressiveErrors == 1
            tempdelg=omARStar(k,:);
            [tempD0g,~,~,nv] = initCovar(tempdelg, tempobv);
            if nv~=0
                tempD0g = eye(length(tempdelg));
            end
        else
            tempdelg = zeros(1,lagOm);
            tempD0g = tempobv;
        end
        [P, ~]= FactorPrecision(tempdelg, tempD0g, 1/tempobv, T);
        S = P\eye(T);
        Slowerinv = chol(S,'lower')\eye(T);
        LL(k) = adjustedlogmvnpdf( ((Slowerinv*tempy') - Slowerinv*(tempx*betaStar(:,k)))', Slowerinv);
    end
    LL = sum(LL);
    bprior = b0.*ones(1,dimx);
    Bprior = (1/B0inv).*eye(dimx);
    priorBeta = zeros(K,1);
    
    for k = 1:K
        priorBeta(k) = logmvnpdf(betaStar(:,k)', bprior, Bprior);
    end
    priorBeta = sum(priorBeta);
    Fpriorstar = zeros(nFactors,1);
    %%%%%%%%%%%%%%
    for j = 1:nFactors
        qq = factorVarStar(j);
        [iP, ss,~,w] =initCovar(factorARStar(j,:), qq);
        if w ~= 0
            iP = eye(length(factorARStar(j,:)));
        end
        Kprecision = FactorPrecision(ss, iP, 1/qq, T);
        Fpriorstar(j) = logmvnpdf(FactorStar(j,:), zeros(1,T ), Kprecision\eye(T));
    end
    Fpriorstar=sum(Fpriorstar);
    
    priorFactorAR = logmvnpdf(reshape(factorARStar', 1, nFactors*lagState),...
        zeros(1,nFactors*lagState), kron(eye(nFactors),G0));
    priorVar = sum(logigampdf(omVarStar,.5.*v0,.5.*d0));
    priorFactorVar = sum(logigampdf(factorVarStar, .5.*s0, .5.*r0));
    
    if autoRegressiveErrors==1
        priorOMAR = logmvnpdf( reshape(omARStar, 1, K*lagOm), zeros(1, K*lagOm), kron(eye(K),G0));
        PRIORS = [priorBeta, Fpriorstar,  priorOMAR, priorFactorAR, priorVar, priorFactorVar];
        
        POSTERIORS = [ piFactor,piBeta, piOMAR, piFactorAR, piOmVar, piFV];
    else
        PRIORS = [priorBeta, Fpriorstar, priorFactorAR, priorVar, priorFactorVar];
        
        POSTERIORS = [piFactor,piBeta,  piFactorAR, piOmVar, piFV];
        
    end
    Summary = [LL;PRIORS';-POSTERIORS']
    ML = sum(Summary)
    % else
    %     fprintf('Not calculating ML\n')
    %     ML=0;
    % end
    fprintf('Baseline Model Estimation\n')
    
end

