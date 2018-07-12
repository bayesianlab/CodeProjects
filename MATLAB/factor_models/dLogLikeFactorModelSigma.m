function [Fdel, Bt] = dLogLikeFactorModelSigma(a, y, mu, SigmaGuess, Sinv)
Sigma = diag(SigmaGuess);
[~,J]= size(Sigma);
T  = length(y)/J;
y = reshape(y, [J,T]);
mu = reshape(mu, [J,T]);
score = zeros(T, J);
SigmaInv = inv(Sigma);
Precision = inv(Sinv);

for j = 1 : J
    delsigma = zeros(J,J);
    delsigma(j,j) = 1;
    for t = 1 : T
        invcondvar = Precision(t,t);
        condvar = inv(Precision(t,t));
        WoodInv = inv( invcondvar + a'*SigmaInv*a );
        Vinv = SigmaInv - (SigmaInv * (a' * WoodInv * a) * SigmaInv);
        st = Vinv * (y(:,t) - mu(:,t));
        Subtract = trace(Vinv * delsigma);
        score(t,j) = Subtract-(st' * delsigma * st);
    end
end
Fdel = -.5*(1/T)*sum(score)';
Bt = zeros(J,J);
for t = 1 : T
    Bt = Bt + score(t,:)' * score(t,:);
end
Bt = (1/T) * Bt;



