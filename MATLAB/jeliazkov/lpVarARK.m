function [ sHatSqd ] = lpVarARK(sample, batches, a, b, mu, sigma, precision, cv)
[N,~,~] = size(sample);
f = floor(N/batches);
nb = 1:batches;
indx = nb.*f;
c=1;
d=1;
lpBar = zeros(batches,1);
batchLen = indx(2) - indx(1);
for i = 1:batches
    s = squeeze(sample(d:indx(c),:, :));
    d = indx(c)+1;
    zStar = squeeze(mean(s(:,1,:)))';
    K = arkTransitionKernel(a,b,zStar, s, mu, precision, cv);
    lpBar(c) = log( mvnpdf(zStar, mu, sigma)/mean(prod(K,2)) );
    c = c + 1;
end
lpBarBar = mean(lpBar);
weight1 = batchLen/(batches-1);
ssr = sum((lpBar - lpBarBar).^2);
sHatSqd = sqrt((1/N)*weight1*ssr);
end


