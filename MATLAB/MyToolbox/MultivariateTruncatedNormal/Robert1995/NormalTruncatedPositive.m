function [draws] = NormalTruncatedPositive(mu, sigma2, N)
draws = zeros(N,1);
newCut = -mu/sqrt(sigma2);
for i = 1:N
    if newCut > 5
        draws(i)=mu+sqrt(sigma2)*drawRobertTruncated(newCut);
    else
        draws(i) = mu + sqrt(sigma2)*oneSidedTruncatedNormal(newCut);
    end     
end
end

