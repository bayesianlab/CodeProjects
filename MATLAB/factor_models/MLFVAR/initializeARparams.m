function [arcoefs] = initializeARparams(K, p)


arcoefs = zeros(K,p);
insideUnitCircle = 1;
while insideUnitCircle == 1
    gammas = unifrnd(.5,.7,K,1);
    for k = 1:p
        
        arcoefs(:, p+1-k) = gammas.^(k+1);
    end
    [~,~, g] = initCovar(arcoefs);
    insideUnitCircle = sum(eig(g) > 1);
end

end

