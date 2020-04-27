function [PosteriorPredictive] = HdfvarPredict(PredictOut, yt, Xt, Ft, InfoCell, obsPrecision, currobsmod, stateTransitions,...
    factorVariance, beta0, B0inv,  a0, A0inv, v0, r0, g0, G0, s0, d0, Sims, PosteriorPredictive)
if PredictOut ==0
    [~,~,d]=size(PosteriorPredictive);
    PosteriorPredictive = PosteriorPredictive(:,:,d:(-1):1);
    return
end
PredictOut = PredictOut - 1;
fprintf('Prediction runs %i\n', PredictOut+1)
levels = length(InfoCell);
[K,T] = size(yt);
KT = K*T;
SurX = surForm(Xt,K);
[~, dimX] = size(Xt);
FtIndexMat = CreateFactorIndexMat(InfoCell);
subsetIndices = zeros(K,T);
for k = 1:K
    subsetIndices(k,:)= k:K:KT;
end
[nFactors, lagState] = size(stateTransitions);
keepOmMeans = currobsmod;
keepOmVariances = currobsmod;
runningAvgOmMeans = zeros(K,levels);
runningAvgOmVars = ones(K,levels);
[Identities, ~, ~] = MakeObsModelIdentity( InfoCell);
identification=2;

storeVAR = zeros(dimX,K,Sims);
storeOM = zeros(K, levels, Sims);
storeFt = zeros(nFactors, T, Sims);
storeStateTransitions = zeros(nFactors, lagState, Sims);
storeObsPrecision = zeros(K, Sims);
storeFactorVar = zeros(nFactors,Sims);
storeFtpred = zeros(nFactors, Sims);
storeYtpred = zeros(K, Sims); 

for sim = 1:Sims
    fprintf('predSim %i\n', sim)
    %% Draw VAR params
    [VAR, Xbeta] = VAR_ParameterUpdate(yt, Xt, obsPrecision,...
        currobsmod, stateTransitions, factorVariance, beta0,...
        B0inv, FtIndexMat, subsetIndices);
    
    %% Draw loadings and factors
    [currobsmod, Ft, keepOmMeans, keepOmVariances]=...
        LoadingsFactorsUpdate(yt, Xbeta, Ft, currobsmod, stateTransitions,...
        obsPrecision, factorVariance, Identities, InfoCell, keepOmMeans, keepOmVariances,...
        runningAvgOmMeans, runningAvgOmVars, a0, A0inv);
    
    %% Variance
    StateObsModel = makeStateObsModel(currobsmod, Identities, 0);
    
    ConditionalMean = (StateObsModel*Ft) + Xbeta;
    resids = yt - ConditionalMean;
    obsVariance = kowUpdateObsVariances(resids, v0,r0,T);
    obsPrecision = 1./obsVariance;
    
    %% Factor AR Parameters
    for n=1:nFactors
        stateTransitions(n,:)= drawStateTransitions(stateTransitions(n,:), Ft(n,:), factorVariance(n), g0,G0);
    end
    
    if identification == 2
        factorVariance = drawFactorVariance(Ft, stateTransitions, factorVariance, s0, d0);
    end
    ytpred = SimPrediction(ConditionalMean(:,T), obsVariance);
    FtConditionalMean = stateTransitions.*Ft(:,T);
    Ftpred = SimPredictionFt(FtConditionalMean, factorVariance);
    
    storeVAR(:,:,sim)=VAR;
    storeOM(:,:,sim) = currobsmod;
    storeStateTransitions(:,:,sim) = stateTransitions;
    storeFt(:,:,sim) = Ft;
    storeObsPrecision(:,sim) = obsPrecision;
    storeFactorVar(:,sim) = factorVariance;
    storeFtpred(:,sim) = Ftpred;
    storeYtpred(:,sim) = ytpred;
end

obsPrecision=mean(storeObsPrecision,2);
currobsmod = mean(storeOM,3);
stateTransitions = mean(storeStateTransitions,3);
factorVariance = mean(storeFactorVar,2);
beta0 = mean(storeVAR,3);


Xstar = zeros(K,dimX);
nSeriesPerY = dimX-1;
nLowestLevelRegions = K/nSeriesPerY;
select2 = 1:(dimX-1);

for c = 1:nLowestLevelRegions
    rows = select2 + (c-1)*nSeriesPerY;
    Xstar(rows,:) =repmat([1, yt(rows, T)'], (dimX-1),1);
end
Xt = [Xt;Xstar];
yt = [yt,mean(storeYtpred,2)];
Ft = [Ft, mean(Ftpred,2)];


PosteriorPredictive(:,:,PredictOut+1) = storeYtpred;
[PosteriorPredictive] = HdfvarPredict(PredictOut, yt, Xt, Ft, InfoCell, obsPrecision, currobsmod, stateTransitions,...
    factorVariance, beta0, B0inv,  a0, A0inv, v0, r0, g0, G0, s0, d0, Sims, PosteriorPredictive);
end

