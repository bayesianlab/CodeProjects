function [ simP ] = arkMethod( X,beta, sims)
[r,~] = size(X);
simP = mean(0 < normrnd(repmat(X*beta, 1, sims), 1,r,sims),2)
end

