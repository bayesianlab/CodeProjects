function [LL] = crt_mvpro(y, mu, Sigma, sims)
[r, c] = size(mu);
A = zeros(r,c);
B = zeros(r,c);
init = zeros(c,1);
burnin = floor(.1*sims);
LL = zeros(r,1);
for i = 1:r
    for j = 1:c
        if y(i,j) > 0
            A(i,j) = 0;
            B(i,j) = inf;
        else
            A(i,j) = -inf;
            B(i,j) = 0;
        end
    end
    sample = tmultnormrnd(A(i,:), B(i,:), mu(i,:), Sigma, sims, init);
    sample = sample(burnin:sims,:);
    zs = mean(sample,1)';
    K = gibbsKernel(A(i,:), B(i,:),mu, Sigma, sample);
    lmpk = log(mean(prod(K,2)));
    LL(i) = (log(mvnpdf(zs', mu(i,:), Sigma)) - log(mean(prod(K,2))));
end
LL = sum(LL);
end

