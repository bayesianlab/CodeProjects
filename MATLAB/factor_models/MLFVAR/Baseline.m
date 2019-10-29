function [storeMeans, storeLoadings, storePhi, storeFt, storeObsV] = ...
    Baseline(InfoCell,yt, xt, Ft, MeansLoadings, deltas, gammas, Sims, bn)
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
[K,T] = size(yt)
igParamA = .5.*(igPriorA + T);
[KT, meanIndex]= size(xt);
[nFactors,  lagState] = size(gammas);
meanRange = 1:meanIndex;
factorRange = meanIndex+1:meanIndex + nFactors;
[~, lagObs] = size(deltas);
[Identities,~,~]=MakeObsModelIdentity(InfoCell);
levels=length(InfoCell);
IT = ones(T,1);
FtIndexMat = CreateFactorIndexMat(InfoCell);
subsetIndices = zeros(K,T);
for k = 1:K
    subsetIndices(k,:)= k:K:KT;
end
lagind = 1:lagObs;
IT = speye(T);

%% Posterior Storage
Runs = Sims-bn;
storeMeans = zeros(K,Runs);
storeLoadings = zeros(K, nFactors, Runs);
storePhi = zeros(K, lagObs,Runs);
storeFt = zeros(nFactors, T, Runs);
storeObsV = zeros(K,Runs);

%% Initializations
obsVariance = ones(K,1);
factorVariance = ones(nFactors,1);
beta = zeros(meanIndex+nFactors,K);
meanFunction = zeros(meanIndex,K);
loadings = zeros(nFactors,K);
mut=zeros(K,T);
phi = zeros(lagObs, K);

meanFunction(:,:) = MeansLoadings(meanIndex,:)
loadings(:,:) = MeansLoadings(factorRange, :)
for i = 1:Sims
%     fprintf('Simulation i = %i\n',i)
    for k = 1:K
        tempI = subsetIndices(k,:);
        tempy = yt(k,:);
        tempx=[xt(tempI,:),Ft(FtIndexMat(k,:),:)'];
        tempdel=deltas(k,:);
        tempobv = obsVariance(k);
        [tempD0, ~] = initCovar(tempdel);
        [beta(:,k), ~,~,ystar,xstar, Cinv] = drawBeta(tempy, tempx,  tempdel, tempobv, tempD0);
        meanFunction(:,k) = beta(meanRange,k);
        loadings(:,k) = beta(factorRange,k);
        phi(:,k) = drawPhi(tempy, tempx, beta(:,k),tempdel, tempobv, Cinv);
        igParamB=igPriorB+sum((ystar - beta(:,k)'*xstar').^2,2);
        obsVariance(k) = 1./gamrnd(igParamA, 2./igParamB);
    end
    
%     [D0, ssDeltas] = initCovar(deltas);
%     [L0, ssGammas] = initCovar(gammas);
%     [D,H] = FactorPrecision(ssDeltas,D0, 1./obsVariance,T);
%     Hinv = H\eye(KT);
%     Lambda = FactorPrecision(ssGammas,L0, 1./factorVariance, T);
%     z=yt(:)-Hinv*surForm(xt,K)*meanFunction(:);
%     HinvD = Hinv*D;
%     A = makeStateObsModel(loadings', Identities, 0);
%     KronLoads = kron(IT,A);
%     KronLoadsHinvD = KronLoads'*HinvD;
%     Omega = (KronLoadsHinvD*KronLoads + Lambda)\eye(nFactors*T, nFactors*T);
%     om = Omega*KronLoadsHinvD*z;
%     Ft = reshape(om + chol(Omega, 'lower')*normrnd(0,1,nFactors*T,1), nFactors,T);
    
    
    if i > bn
        v = i - bn;
        storeMeans(:,v)=beta(meanRange,:)';
        storeLoadings(:,:,v) = beta(factorRange,:)';
        storePhi(:, :,v) = phi';
        storeFt(:,:,v) = Ft;
        storeObsV(:,v) = obsVariance;
    end
end
end

