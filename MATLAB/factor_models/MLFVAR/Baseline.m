function [storeMeans, storeLoadings, storePhi, storeFt, storeObsV] = ...
    Baseline(yt, xt, Ft, MeansLoadings, deltas, gammas, Sims, bn)
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
igPriorA = 3;
igPriorB = 6;
[K,T] = size(yt);
igParamA = .5.*(igPriorA + T);
[KT, dimx]= size(xt);
[nFactors,  lagState] = size(gammas);
meanIndex = dimx-nFactors;
meanRange = 1:meanIndex;
factorIndex = meanIndex+1:dimx;
[~, lagObs] = size(deltas);

IT = ones(T,1);

obsVariance = ones(K,1);
factorVariance = ones(nFactors,1);
X = zeros(K*T, (1 + nFactors)*K);
R = zeros(K*lagObs,T-lagObs);
lagind = 1:lagObs;
beta = zeros(dimx,K);
meanFunction = zeros(length(meanRange),K);
loadings = zeros(length(factorIndex),K);
mut=zeros(K,T);
phi = zeros(lagObs, K);

IT = speye(T);

Runs = Sims-bn;
storeMeans = zeros(K,Runs);
storeLoadings = zeros(K, nFactors, Runs);
storePhi = zeros(K, lagObs,Runs);
storeFt = zeros(nFactors, T, Runs);
storeObsV = zeros(K,Runs);
subsetIndices = zeros(K,T);
for k = 1:K
    subsetIndices(k,:)= k:K:KT;
end

meanFunction(:,:) = MeansLoadings(meanIndex,:)
loadings(:,:) = MeansLoadings(factorIndex, :)
for i = 1:Sims
    for k = 1:K
                tempI = subsetIndices(k,:);
                tempy = yt(k,:);
                tempx = xt(tempI,:);
                tempdel=deltas(k,:);
                tempobv = obsVariance(k);
                [beta(:,k), ~,~,ystar,xstar] = drawBeta(tempy, tempx,  tempdel, tempobv);
                meanFunction(:,k) = beta(meanIndex,k);
                loadings(:,k) = beta(factorIndex,k);
                mut(k,:) = beta(:,k)'*tempx';
                et = tempy-mut(k,:);
                phi(:,k) = drawPhi(tempy,et, tempdel, tempobv);
                igParamB=igPriorB+sum((ystar - MeansLoadings'*xstar').^2,2);
                obsVariance = 1./gamrnd(igParamA, 2./igParamB);
    end
    %     [D0, ssDeltas] = initCovar(deltas);
    %     [L0, ssGammas] = initCovar(gammas);
    %     [D,H] = FactorPrecision(ssDeltas,D0, 1./obsVariance,T);
    %     Hinv = H\eye(KT);
    %     Lambda = FactorPrecision(ssGammas,L0, 1./factorVariance, T);
    %     z=yt(:)-Hinv*surForm(xt(:,meanRange),K)*meanFunction(:);
    %     HinvD = Hinv*D;
    % Need to define a better A when World Region and country are here
    % Like in Hdfvar
    %     KronLoads = kron(IT,loadings');
    %     KronLoadsHinvD = KronLoads'*HinvD;
    %     Omega = (KronLoadsHinvD*KronLoads + Lambda)\eye(nFactors*T, nFactors*T);
    %     om = Omega*KronLoadsHinvD*z;
    %     Ft = reshape(om + chol(Omega, 'lower')*normrnd(0,1,nFactors*T,1), nFactors,T);

    
    if i > bn
        v = i - bn;
        storeMeans(:,v)=beta(meanRange,:)';
        storeLoadings(:,:,v) = beta(factorIndex,:)';
        storePhi(:, :,v) = phi';
        storeFt(:,:,v) = Ft;
        storeObsV(:,v) = obsVariance;
    end
end
end

