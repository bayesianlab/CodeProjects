function [Fdel, Bt] = OrdinalProbitGradient(delta,y,X,beta,h)
NumChoices = length(delta) + 2;
N = length(y);
Fdel = zeros(NumChoices-2,1);
twoh = 2*h;
score = zeros(N, NumChoices-2);
for j = 1:NumChoices - 2
    deltap = delta;
    deltam = delta;
    deltap(j) = deltap(j) + h;
    deltam(j) = deltap(j) - h;
    GradVecM = GradOrdProbLike(deltam,y,X,beta);
    GradVecP = GradOrdProbLike(deltap,y,X,beta);
    score(:,j) = (GradVecP - GradVecM)./twoh;
    Fdel(j) = sum(score)/N;
end
Bt = zeros(NumChoices-2,NumChoices-2);
for i = 1:N
   Bt = Bt + (score(i,:)'*score(i,:)); 
end
Bt = Bt./N;
end

