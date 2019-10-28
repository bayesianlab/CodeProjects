function [arcoefs] = initializeARparams(K, p)
% returns [lagp, lagp-1,...,lag1]
arcoefs = zeros(K,p);
notvalid = 1;
while notvalid == 1
    for k = 1:K
        ar = unifrnd(.01, .9);
        for b = 1:p
            arcoefs(k,p+1-b) = ar.^(b);
        end
    end
    [~,~,~, notvalid] = initCovar(arcoefs);
    
end

