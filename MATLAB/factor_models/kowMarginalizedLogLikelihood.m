function [ll] = kowMarginalizedLogLikelihood(demeanedy, Variance,K,T)
ll=0;
for t = 1:T
    ll = ll + log(mvnpdf(demeanedy(:,t), zeros(K,1), Variance));
end
end

