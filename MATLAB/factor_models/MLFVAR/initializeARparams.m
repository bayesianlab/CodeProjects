function [arcoefs] = initializeARparams(K, p)
% returns [lagp, lagp-1,...,lag1]
arcoefs = zeros(K,p);
nv = zeros(1,K);
notvalid = 1;

while notvalid == 1
    for k = 1:K
        ar = unifrnd(0, .3);
        for b = 1:p
            arcoefs(k,p+1-b) = ar.^(b);
        end
    [~,~,~,nv(k)] = initCovar(arcoefs(k,:)) ;
    end
    if sum(nv) == 0
        notvalid = 0;
    end
    
end

