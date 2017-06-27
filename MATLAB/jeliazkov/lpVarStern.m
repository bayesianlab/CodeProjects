function [ sHatSqd ] = lpVarStern(u, u1CondMeanVar, batches, a,b,mu, precision, cv)
[N,~] = size(u);
f = floor(N/batches);
nb = 1:batches;
indx = nb.*f;
c=1;
d=1;
lpBar = zeros(batches,1);
batchLen = indx(2) - indx(1);
for i = 1:batches
    uSample = u(d:indx(c),:);
    u1MeanVar = u1CondMeanVar(d:indx(c),:);
    d = indx(c)+1;
    uStar = mean(uSample,1);
    K = sternKernel(a,b,u1MeanVar,uStar, uSample, mu,precision, cv);
    lpBar(c) = log( mvnpdf(uStar, mu, precision)/mean(prod(K,2)) );
    c = c + 1;
end
lpBarBar = mean(lpBar);
weight1 = batchLen/(batches-1);
ssr = sum((lpBar - lpBarBar).^2);
sHatSqd = sqrt((1/N)*weight1*ssr);
end

