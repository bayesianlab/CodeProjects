function [ smoothedState, smoothedStateVar] =...
    forwardBackwardSmoother(y, mu, FullSigma, StateTransition, ObsModel,...
    state0, stateVar0, nu )
K = size(FullSigma,1);
T = length(y)/K;

index =1:K;
stateUpdateSave = zeros(T,1);
stateVarPredictSave = zeros(T,1);
stateVarUpdateSave = zeros(T,1);

for t = 1:T
    select = index + (t-1)*K;
    % Step 1 predict
    statePredict = StateTransition*state0;
    stateVarPredict = (StateTransition*stateVar0 *StateTransition') + nu;
    stateVarPredictSave(t) = stateVarPredict;

    % Step 2 update
    resid = y(select) - mu(select) - ObsModel*statePredict;
    residvar = ObsModel*stateVarPredict*ObsModel' + FullSigma;

    % Filter
    KalmanGain = stateVarPredict*ObsModel'/residvar;
    state0 = statePredict + KalmanGain*resid;
    stateUpdateSave(t) = state0;
    stateVar0 = stateVarPredict - KalmanGain*ObsModel*stateVarPredict;
    stateVarUpdateSave(t) = stateVar0;
    
end
smoothedState = zeros(T,1);
smoothedState(T) = state0;
smoothedStateVar =zeros(T,1);
smoothedStateVar(T) = stateVar0;
for t = (T-1):-1:1
   Smootht = stateVarUpdateSave(t)*...
       StateTransition'*(1/stateVarPredictSave(t+1));
   smoothedState(t) = stateUpdateSave(t) + ...
       Smootht*(smoothedState(t+1) -...
       StateTransition*stateUpdateSave(t));
   smoothedStateVar(t) = stateVarUpdateSave(t) - ...
       (Smootht*(smoothedStateVar(t+1) -...
       stateVarPredictSave(t+1))*Smootht');
end

end