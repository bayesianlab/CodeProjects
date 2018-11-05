function [ Si, p] = kowMakeVariance(  stackedTransitions,  stateVariance, T )
[k, lags] = size(stackedTransitions);
Tmlag = T- lags;
Phi = [repmat(stackedTransitions, Tmlag,1), ones(k*Tmlag,1)];
p = spdiags(Phi,[0:k:k*lags+1],k*Tmlag, k*T);
p = p(1:k, 1:k*lags);
p=full([spdiags(ones(k*(lags-1),1), k, k*(lags-1), k*lags);p]);
P0 = (eye(k*lags) - p)\(eye(k*lags).*stateVariance);
H = [speye(k*lags, k*T); spdiags(Phi,[0:k:k*lags+1], k*Tmlag, k*T)];
sv = repmat(1/stateVariance, k*Tmlag);
Si = [[P0, sparse(k*lags, k*Tmlag)]; spdiags(sv, k*lags, k*Tmlag, k*T)];
Si=H*Si*H';
end

