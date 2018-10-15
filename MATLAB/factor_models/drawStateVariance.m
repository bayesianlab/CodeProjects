function [ omega2 ] = drawStateVariance(state, stateTransition, del0, alpha0 )
T = length(state);
statestar = state;
statehat =state;
statestar(1) = state(1) * sqrt(1-stateTransition^2);
statehat(1) = 0;
statehat(2:end) = stateTransition.*state(1:end-1);
difference = statestar - statehat;
delStar = .5*(del0 + difference*difference');
alphaStar = .5*(alpha0 + T);
omega2 = 1/gamrnd(alphaStar, 1/delStar);
end

