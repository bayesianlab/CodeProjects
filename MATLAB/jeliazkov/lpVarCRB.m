function [ sHatSqd ] = lpVarCRB(sample, batches, a,b,mu, sigma, precision)
[N,~,~] = size(sample);
f = floor(N/batches);
nb = 1:batches-1;
indx = nb.*f;
c=1;
d=1;
lpBar = zeros(batches-1,1);
for i = 1:batches-1
    s = sample(d:indx(c),:, :);
    [row,~] = size(s);
    d = indx(c)+1;
    [zStar, fzStar] = crbMarginalLikelihood(a,b,mu,precision,s, row);
    lpBar(c) = logProbMCMC(zStar,fzStar, mu, sigma);
    c = c + 1;
end
lastBatchLen = length(d:N);
[zStar, fzStar] = crbMarginalLikelihood(a,b,mu,precision,s, row);
lpBar(batches) = logProbMCMC(zStar, fzStar, mu, sigma);
lpBarBar = mean(lpBar);
weight1 = lastBatchLen/(batches-1);
ssr = sum((lpBar - lpBarBar).^2);
sHatSqd = sqrt((1/N)*weight1*ssr);
end