function [Bt] = OrdinalProbitObservedHessian(delta,y,X,beta,h)
NumChoices = length(delta) + 2;
N = length(y);
NoPerturb = GradOrdProbLike(delta,y,X,beta);
score = zeros(N, NumChoices-2);
for j = 1:NumChoices - 2
    deltap = delta;
    delta(j) = deltap(j) + h;
    GradVec = GradOrdProbLike(delta,y,X,beta);
    score(:, j) = (GradVec - NoPerturb)./h;
end
Bt = zeros(NumChoices-2,NumChoices-2);
for i = 1:N
   Bt = Bt + (score(i,:)'*score(i,:)); 
end
Bt = Bt./N;
end

