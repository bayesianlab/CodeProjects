function [Fdel, Bt] = dLogLikeFactorModel(a, y, mu, Sigma, Sinv)
[~,J]= size(Sigma);
[r,C] = size(a);
T  = length(y)/J;
y = reshape(y, [J,T]);
mu = reshape(mu, [J,T]);
score = zeros(T, J);
SigmaInv = inv(Sigma);
Precision = inv(Sinv);

for j = 1 : C*r
    dela = zeros(1,r*C)';
    dela(j) = 1;
    for t = 1 : T
        invcondvar = Precision(t,t);
        condvar = inv(Precision(t,t));
        WoodInv = inv( invcondvar + a'*SigmaInv*a );
        Vinv = SigmaInv - (SigmaInv * (a' * WoodInv * a) * SigmaInv);
        st = Vinv * (y(:,t) - mu(:,t));
        deriv = a*condvar*dela';
        Subtract = trace(Vinv * deriv);
        score(t,j) = (st' * deriv' * st) - Subtract;
    end
end
Fdel = (1/T)*sum(score)';
Bt = zeros(r*C,r*C);
for t = 1 : T
    Bt = Bt + score(t,:)' * score(t,:);
end
Bt = (1/T) * Bt;

