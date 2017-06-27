function [ sHatSqd ] = lpVarASK(sample, batches, a,b,mu, sigma)
[N,~] = size(sample);
f = floor(N/batches);
nb = 1:batches;
indx = nb.*f;
c=1;
d=1;
lpBar = zeros(batches,1);
batchLen = indx(2) - indx(1);
for i = 1:batches
    z = sample(d:indx(c),:);
    d = indx(c)+1;
    zStar = mean(z,1);
    K = askKernel(a,b,z, zStar,mu,sigma);
    lpBar(c) = log( mvnpdf(zStar, mu, sigma)/mean(prod(K,2)) );
    c = c + 1;
end
lpBarBar = mean(lpBar);
weight1 = batchLen/(batches-1);
ssr = sum((lpBar - lpBarBar).^2);
sHatSqd = sqrt((1/N)*weight1*ssr);
end


