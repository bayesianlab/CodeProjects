function [ acceptedval ] = drawStateTransition(state, stateTransition,...
    statePriorMean, statePriorCov, omega2)

sigma = 1/(statePriorMean + state(1:end-1)*state(1:end-1)'/omega2);
mu = sigma*( (statePriorCov*statePriorMean) +...
    (state(1:end-1)*state(2:end)')/omega2);

proposal = normrnd(mu,sigma,1);
mh= min(0,log(normpdf(state(1), 0,omega2/(1-proposal^2))) -...
        log(normpdf(state(1), 0,omega2/(1-stateTransition^2))));
if log(unifrnd(0,1,1)) < mh
    acceptedval = proposal;
else
    acceptedval = stateTransition;
end

end

