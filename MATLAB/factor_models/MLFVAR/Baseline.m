function [storeMeans, storeLoadings, storeOmArTerms,...
    storeStateArTerms, storeFt, storeObsV] = ...
    Baseline(InfoCell,yt, xt, Ft, MeansLoadings, omArTerms,...
    stateArTerms, Sims, bn)
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

% deltas comes in as  (p lags)
% [delta1p ... delta11;
% ...
% deltaKp ... deltaK1]

% gammas comes in as deltas.
%% Setup and indices
igPriorA = 3;
igPriorB = 6;
[K,T] = size(yt);
[KT, meanIndex]= size(xt);
[nFactors,  lagState] = size(stateArTerms);
meanRange = 1:meanIndex;
levels=length(InfoCell);
factorRange = meanIndex+1:meanIndex + levels ;
[~, lagObs] = size(omArTerms);
[Identities,~,~]=MakeObsModelIdentity(InfoCell);
restrictions = restrictedElements(InfoCell);
FtIndexMat = CreateFactorIndexMat(InfoCell);
subsetIndices = zeros(K,T);
for k = 1:K
    subsetIndices(k,:)= k:K:KT;
end
lagind = 1:lagObs;
IT = eye(T);
[Identities, sectorInfo, factorInfo] = MakeObsModelIdentity( InfoCell);

%% Posterior Storage
Runs = Sims-bn;
storeMeans = zeros(K,Runs);
storeLoadings = zeros(K, levels, Runs);
storeOmArTerms = zeros(K, lagObs,Runs);
storeStateArTerms = zeros(nFactors, lagState,Runs);
storeFt = zeros(nFactors, T, Runs);
storeObsV = zeros(K,Runs);

%% Initializations
igParamA = .5.*(igPriorA + T);
obsVariance = ones(K,1);
factorVariance = ones(nFactors,1);
beta = zeros(levels+meanIndex,K);
mut=zeros(K,T);
meanFunction = MeansLoadings(:,meanRange)';
loadings = MeansLoadings(:, factorRange);
fakeX = zeros(T,1);
fakeB = zeros(1,1);
for i = 1:Sims
    fprintf('Simulation i = %i\n',i)
    
    %% Draw Mean, Loadings and AR Parameters
    for k = 1:K
%                 tempI = subsetIndices(k,:);
%                 tempy = yt(k,:);
%                 tempx=[xt(tempI,:),Ft(FtIndexMat(k,:),:)'];
%                 tempdel=omArTerms(k,:);
%                 tempD0 = initCovar(omArTerms(k,:));
%                 tempobv = obsVariance(k);
%                 [beta(:,k), ~,~,ystar,xstar, Cinv] = drawBeta(tempy, tempx,  tempdel, tempobv, tempD0);
%                 meanFunction(meanRange,k) = beta(meanRange,k)';
%                 loadings(k,:) = beta(factorRange,k);
%                 loadings(k,:) = (loadings(k,:) + restrictions(k,:)) - (loadings(k,:).*restrictions(k,:));
%                 betaUpdate = [meanFunction(meanRange,k); loadings(k,:)'];
%                 betaUpdate = MeansLoadings(k,:)';
%                 omArTerms(k,:) = drawPhi(tempy, tempx, betaUpdate,tempdel, tempobv, Cinv);
%                 igParamB=igPriorB+sum((ystar - beta(:,k)'*xstar').^2,2);
%                 obsVariance(k) = 1./gamrnd(igParamA, 2./igParamB);
    end
    
    %% Draw Factors
%     SurX = surForm(xt,K);
%     mu1t = reshape(SurX*meanFunction(:),K,T);
%     demuyt = yt - mu1t;
%     c=0;
%     for q = 1:levels
%         Info = InfoCell{1,q};
%         COM = makeStateObsModel(loadings, Identities, q);
%         alpha =loadings(:,q);
%         tempyt = demuyt - COM*Ft;
%         for w = 1:size(Info,1)
%             % Factor level
%             c=c+1;
%             subsI = Info(w,1):Info(w,2);
%             commonPrecisionComponent = zeros(T,T);
%             commonMeanComponent = zeros(T,1);
%             for k = subsI
%                 % Equation level
%                 ty = tempyt(k,:);
%                 [D0, ssOmArTerms] = initCovar(omArTerms(k,:));
%                 OmPrecision = FactorPrecision(ssOmArTerms, D0, 1./obsVariance(k), T);
%                 A = kron(IT,alpha(k,:));
%                 commonMeanComponent = commonMeanComponent + A'*OmPrecision*ty(:);
%                 commonPrecisionComponent = commonPrecisionComponent + A'*OmPrecision*A;
%             end
%             [L0, ssGammas] = initCovar(stateArTerms(c,:));
%             StatePrecision = FactorPrecision(ssGammas, L0, 1./factorVariance(c), T);
%             OmegaInv = commonPrecisionComponent + StatePrecision;
%             Linv = chol(OmegaInv,'lower')\IT;
%             omega = Linv'*Linv*commonMeanComponent;
%             Ft(c,:) = omega + Linv' * normrnd(0,1,T,1);
%         end
%     end
    
    %% Draw Factor AR Parameters
    for n=1:nFactors
        [L0, ~] = initCovar(stateArTerms(n,:));
        Linv = chol(L0,'lower')\eye(lagState);
        stateArTerms(n,:) = drawPhi(Ft(n,:), fakeX, fakeB, stateArTerms(n,:), factorVariance(n), Linv);
    end
    
    %% Store post burn-in runs 
    if i > bn
        v = i - bn;
        storeMeans(:,v)=meanFunction;
        storeLoadings(:,:,v) = loadings;
        storeOmArTerms(:, :,v) = omArTerms;
        storeStateArTerms(:,:,v) = stateArTerms;
        storeFt(:,:,v) = Ft;
        storeObsV(:,v) = obsVariance;
    end
end
end

