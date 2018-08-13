clear;
clc;
N = 100;
X = [ones(N,1), normrnd(0,1, N,1)];
e = normrnd(0,1,N,1);
b = [1; .75];
stops = zeros(10000,1);
for j = 1:20
    for i = 1:1000
        morenoise = normrnd(0,1,N,1);
        y = X*b + e;
        y2 = X*b + e +  morenoise;
        bols = inv(X'*X)*X'*y;
        bols2 = inv(X'*X)*X'*y2;
        err = y - X*bols;
        err2 = y2 - X*bols2;
        errSqd = err'*err;
        errSqd2 = err2'*err2;
        shatSqd = errSqd/(N-2-1);
        shatSqd2 = errSqd2/(N-2-1);
        seBeta = diag(sqrt(inv(X'*X)*shatSqd));
        seBeta2 = diag(sqrt(inv(X'*X)*shatSqd2));
        tstat = bols./seBeta;
        tstat2 = bols2./seBeta2;
        if tstat(2) < tstat2(2)
            stops(j) = i;
            fprintf('Covariance \n')
            covxy = cov(X(:,2), y)
            covxy2 = cov(X(:,2), y2)
            fprintf('Sigma hat \n')
            s_hats = [shatSqd, shatSqd2]
            t_Stats = [tstat(2), tstat2(2)]
            break
        end
    end
end
hist(stops, 50)
