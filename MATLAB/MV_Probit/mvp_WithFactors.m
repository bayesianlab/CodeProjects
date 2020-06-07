function [storeBeta, storeFt, storeSt, storeFv, storeOv, storeOm, storeD] = mvp_WithFactors(yt, X, Sigma0,...
    Sims,bn, InfoCell, b0, B0,s0, S0, v0, r0, g0, G0, a0, A0)
[K,T]=size(yt);
[~,P]=size(X);
KT =K*T;
KP = K*P;
IKP = eye(KP);
surX = surForm(X,K);
subsetIndices=reshape(1:KT, K,T);
IK = eye(K);
ZeroK = zeros(1,K);
FtIndexMat = CreateFactorIndexMat(InfoCell);
levels = size(InfoCell,2);
nFactors = sum(cellfun(@(x)size(x,1), InfoCell));
[Identities, ~, ~] = MakeObsModelIdentity( InfoCell);
lags = size(g0,1);
stateTransitions = zeros(size(g0,1), nFactors);
factorVariance = ones(nFactors,1);

B0inv = B0\eye(size(b0,1));
A0inv = 1/A0;
beta = repmat(b0,K,1);
b0 = repmat(b0, 1,K);

zt = yt;

Runs = Sims-bn;
storeBeta = zeros(KP,Runs);
storeFt = zeros(nFactors, T, Runs);
storeSt = zeros(nFactors, lags, Runs);
storeFv = zeros(nFactors, Runs);
storeOv = zeros(K,Runs);
storeOm = zeros(K, levels, Runs);
storeD = zeros(K,Runs);
mut = reshape(surX*beta,K,T);

obsVariance = Sigma0;
obsPrecision = 1./Sigma0;
currobsmod = setObsModel(ones(K,levels), InfoCell);

currobsmod(1) = 1/sqrt(2);

keepOmMeans = currobsmod;
keepOmVariances = currobsmod;
runningAvgOmMeans = zeros(K,levels);
runningAvgOmVars = ones(K,levels);
Ft = normrnd(0,1,nFactors,T);
for s = 1:Sims
    fprintf('Simulation %i\n', s)
    % Sample latent data
    zt = mvp_latentDataDraw(zt,yt,mut, diag(Sigma0));
    
%     % Sample beta
%     [beta, Xbeta] = VAR_ParameterUpdate(zt, X, obsPrecision,...
%         currobsmod, stateTransitions, factorVariance, b0,...
%         B0inv, FtIndexMat, subsetIndices);
%     
%     % Factors loadings
%     [currobsmod, Ft, keepOmMeans, keepOmVariances, ~, d]=...
%         mvp_LoadFacUpdate(yt, Xbeta, Ft, currobsmod, stateTransitions,...
%         obsPrecision, factorVariance, Identities, InfoCell, keepOmMeans, keepOmVariances,...
%         runningAvgOmMeans, runningAvgOmVars, a0, A0inv);
%     
%     
%     % State transitions
%     for n=1:nFactors
%         stateTransitions(n,:)= drawAR(stateTransitions(n,:), Ft(n,:), factorVariance(n), g0,G0);
%     end
    
    
    
    % Store Posteriors
    if s > bn
%         m = s-bn;
%         storeBeta(:,m) = beta(:);
%         storeFt(:,:,m) = Ft;
%         storeSt(:,:,m) = stateTransitions;
%         storeFv(:,m) = factorVariance;
%         storeOv(:,m) = obsVariance;
%         storeOm(:,:,m) = currobsmod;
%         storeD(:,m) = d;
    end
    
end
end

