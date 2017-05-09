function [ vbatch ] = kernelNSE(a,b,z,mu,sigma, batches)
[tr,c] = size(z);
if tr<c
    z = z';
    [tr,~] = size(z);
end
f = floor(tr/batches);
nb = 1:batches-1;
indx = nb.*f;
c=1;
d=1;
lpBar = zeros(batches,1);
for i = 1:batches-1
    subsamp = d:indx(c);
    zSubSamp = z(subsamp,:);
    zstar = mean(zSubSamp,1);
    kSubSamp = askKernel(a,b,zSubSamp, zstar, mu, sigma);
    mpk = mean(prod(kSubSamp,2));
    lpBar(c) = log(mvnpdf(zstar,mu,sigma)/mpk);
    d = indx(c)+1;
    c = c + 1;
end
lastBatch = d:tr;
zSubSamp = z(lastBatch, :);
zstar = mean(zSubSamp, 1);
kSubSamp = askKernel(a,b,zSubSamp, zstar, mu, sigma);
mpk = mean(prod(kSubSamp,2));
lpBar(batches) = log(mvnpdf(zstar,mu,sigma)/mpk);
vbatch=10*std(lpBar);
end

