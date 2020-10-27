function [draws] = NormalTruncatedTPositive(mu, sigma2, df, N)
draws = zeros(N,1);
W = sqrt( df/chi2rnd(df));
newCut = -mu/(W*sqrt(sigma2));
for i = 1:N
    if newCut > 5
        draws(i)=mu+ W*sqrt(sigma2)*drawRobertTruncated(newCut);
    else
        draws(i) = mu + W*sqrt(sigma2)*oneSidedTruncatedNormal(newCut);
    end
end
end

