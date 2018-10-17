function [storeBeta, storeObsModel, storeState, storeSigmaDiag,...
    storeStateTransition, storeStateVariance  ] = dynfacgibbs(y,X, obsModel,...
    stateTransition,SigmaDiag,stateVariance, b0,B0, obsModelPriorMean,...
    obsModelPriorCov,state0,initialStateVar,stateTransititionPriorMean,...
    stateTransititionPriorCov,sigmaPriorParamA,sigmaPriorParamB,...
    stateVariancePriorParamA,stateVariancePriorParamB, Sims)
% Input: y assumed to be vectorized from format: y_[K,T] K is the 
% equation number T is time periods. 
% X is a vector of predictors in SUR format. 
% obsModel (observation Model of Kalman Filter) contains only the 
% unrestricted elements of a. 
% SigmaDiag is a KxK diagonal matrix
% Output: storeBeta = Vectorized betas.
% All output is saved in a K x N matrix where K is the dimension 
% of the paramaeter and N is the simulation run. 

K = length(SigmaDiag);
T = length(y)/K;
B0inv = B0\eye(size(B0,1));
FullSigma = diag(SigmaDiag);
amean = obsModel;

% Set up F matrix, the precision of the state
h = [ones(T,1).*(-stateTransition), ones(T,1), ones(T,1).*(-stateTransition)];
p = full(spdiags(h,[-1,0],T,T));
S = ones(T,1).*stateVariance;
S = diag(S);
F0 = p*S*p';
Sdiag = diag(F0);
F = F0 + kron(eye(T), [1;obsModel]'*diag(SigmaDiag)*[1;obsModel]);
lowerCholF = chol(F,'lower');

% Storage Conatainers
storeBeta = zeros(length(b0),Sims);
storeObsModel = zeros(length(obsModel),Sims);
storeState = zeros(T, Sims);
storeSigmaDiag = zeros(K,Sims);
storeStateTransition = zeros(length(stateTransition), Sims);
storeStateVariance = zeros(length(stateVariance),Sims);

for i = 1:Sims
    % Update mean function parameters
    [b,B] = updateBetaPriors(y,X,[1;obsModel],stateVariance,F0, SigmaDiag, b0,B0inv);
    b1 = b + chol(B,'lower')*normrnd(0,1,length(b0),1);
    mu1 = X*b1;
    storeBeta(:,i) = b1;
    
    % Update observation model parameters
    derivll = @(guess)DmarginalLogLikelihood(y,mu1,FullSigma,guess,Sdiag);
    [obsModel, amean, ~] = mhStepForA(y,mu1,FullSigma,Sdiag,derivll, amean, ...
        obsModelPriorMean, obsModelPriorCov, 15);
    storeObsModel(:,i) = obsModel;
    
    % Update the state variable
    statemeans = forwardBackwardSmoother(y,mu1,FullSigma,...
                      stateTransition, [1;obsModel], state0, initialStateVar, stateVariance);
    statedraw = (statemeans +  lowerCholF\normrnd(0,1, T,1))';
    storeState(:,i) = statedraw';
    
    % Update observation model covariance matrix
    shapedmu2 = [1;obsModel]*statedraw;
    shapedmu1 = reshape(mu1,K,T);
    shapedy = reshape(y, K,T);
    SigmaDiag = drawSigmaDiag(shapedy, shapedmu1+shapedmu2, sigmaPriorParamA,...
        sigmaPriorParamB);
    FullSigma = diag(SigmaDiag);
    storeSigmaDiag(:,i) = SigmaDiag;
    
    % Update the state transition matrix
    g = drawStateTransition(statedraw, stateTransition, stateTransititionPriorMean,...
        stateTransititionPriorCov, stateVariance);
    storeStateTransition(:, i) = g;
    
    % Update the state variance
    stateVariance = drawStateVariance(statedraw, stateTransition,...
        stateVariancePriorParamA, stateVariancePriorParamB);       
    storeStateVariance(:,i) = stateVariance;
end
end
