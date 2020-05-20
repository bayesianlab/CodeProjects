function [ssgamma] = stateSpaceIt(Gamma,lags)
K=size(Gamma,1);
KL = K*lags;
padding = spdiags(ones(KL),0,K*(lags-1),KL);
ssgamma = [Gamma; padding];

end

