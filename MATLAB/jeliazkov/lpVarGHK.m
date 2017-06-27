function [ sHatSqd ] = lpVarGHK(sample, batches)
[N,~] = size(sample);

f = floor(N/batches);
nb = 1:batches;
indx = nb.*f;
c=1;
d=1;
lpBar = zeros(batches,1);
batchLen = indx(2) - indx(1);
for i = 1:batches
    s = sample(d:indx(c),:);
    [r,~] = size(s);
    lpBar(i, 1) = logProbability(r, s);
    d = indx(c)+1;
    c = c + 1;
end

lpBarBar = mean(lpBar);
weight1 = batchLen/(batches-1);
ssr = sum((lpBar - lpBarBar).^2, 'omitnan');
sHatSqd = sqrt((1/N)*weight1*ssr);
end

