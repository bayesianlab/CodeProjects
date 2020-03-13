function [outputArg1,outputArg2] = mvp_LL(demuyt, Sigma)
[K,T]=size(demuyt);

Precision = Sigma \ eye(K);
expSum = 0;
for t = 1:T
    expSum = expSum + demuyt(:,t)'* Precision * demuyt(:,t);
end
expSum=-.5*expSum;
logdet(
end

