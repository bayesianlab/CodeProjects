function [F, H, Rs, vt] = StateSpaceDGP(Gamma, sigma2, T)



K=size(Gamma,1);
lags= size(Gamma,2)/K;
KL = K*lags;
padding = spdiags(ones(KL),0,K*(lags-1),KL);
ssgamma = [Gamma; padding];
[P0, P0lower, R, notvalid] = CalcInitCovar(ssgamma, sigma2, lags);
F = zeros(KL, T);
vt = zeros(K,T);
vt(:,1) = chol(diag(sigma2),'lower')*normrnd(0,1,K,1);
vt(:,2:T) = normrnd(0,1,K,T-1);
initF = P0lower*normrnd(0,1,KL,1);
F(:,1) = initF;
vt(:,1:lags) = reshape(initF,K,lags);


for t = 2:T    
    F(:, t) = ssgamma*F(:,t-1) + R*vt(:,t);
end
H= HMaker(ssgamma,  T);
Rs = kron(eye(T), R);



end

