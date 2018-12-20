function [  Sprecision, H] = kowMakePrecision(  stackedTransitions,  stateVariance, T )
[k, lags] = size(stackedTransitions);
Tmlag = T- lags;

Phi = [repmat(-stackedTransitions, Tmlag,1), ones(k*Tmlag,1)];

% make H
H = [speye(k*lags, k*T); spdiags(Phi,[0:k:k*lags], k*Tmlag, k*T)];
sv = repmat(1/stateVariance, k*Tmlag);
Sprecision = [[eye(k*lags), sparse(k*lags, k*Tmlag)]; spdiags(sv, k*lags, k*Tmlag, k*T)];
Sprecision=H*Sprecision*H';
end

