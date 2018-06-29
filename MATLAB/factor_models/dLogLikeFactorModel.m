function [Fdel, Bt] = dLogLikeFactorModel(a, y, mu, Sigma, Sinv)
[J,c]= size(a);
T  = length(y)/J;
y = reshape(y, [J,T]);
mu = reshape(mu, [J,T]);
score = zeros(T, J);
inv(Sinv)
S = diag(inv(Sinv))
SigmaInv = inv(Sigma);
for j = 1 : J+c
    dela = zeros(1,J+c);
    dela(j) = 1;
    dela = reshape(dela, J,c)';
    for t = 1 : T
        % variance all wrong, perhaps take conditionals for every t
        WoodInv = inv(S + a'*SigmaInv*a);
        OmegaInv = SigmaInv - (SigmaInv * (a * WoodInv * a') * SigmaInv);
        st = OmegaInv * (y(:,t) - mu(:,t));

        Subtract = trace(OmegaInv*a*dela'.*S(j));
        score(t,j) = (st' * dela * S(j) * a' * st) - Subtract;
    end
end
Fdel = (1/T)*sum(score)';
Bt = zeros(J+c,J+c);

for t = 1 : T
    Bt = Bt + score(t,:)' * score(t,:);
end
Bt = (1/T) * Bt;

