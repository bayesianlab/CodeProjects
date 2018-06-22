function [Fdel, Bt] = dLogLikeFactorModel(a, y, mu, Sigma, sigma2F0inv)
[J,~]= size(Sigma);
T  = length(y)/J;
y = reshape(y, [J,T]);
mu = reshape(mu, [J,T]);
score = zeros(T, J);
F0sigma2 = diag(inv(sigma2F0inv));
SigmaInv = inv(Sigma);
for j = 1 : J
    dela = zeros(J,1);
    dela(j) = 1;
    for t = 1 : T
        WoodInv = inv(F0sigma2(t) + a'*SigmaInv*a);
        OmegaInv = SigmaInv - (SigmaInv * (a * WoodInv * a') * SigmaInv);
        st = OmegaInv * (y(:,t) - mu(:,t));
        Subtract = trace(OmegaInv*a*dela'.*F0sigma2(j));
        score(t,j) = (st' * dela * F0sigma2(j) * a' * st) - Subtract;
    end
end
Fdel = (1/T)*sum(score)';
Bt = zeros(J,J);
for t = 1 : T
    Bt = Bt + score(t,:)' * score(t,:);
end
Bt = (1/T) * Bt;

