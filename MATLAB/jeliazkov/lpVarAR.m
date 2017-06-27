function [ sHatSqd ] = lpVarAR(sample, batches)
[N,c] = size(sample);
if N<c
    sample = sample';
    [N,~] = size(sample);
end
f = floor(N/batches);
nb = 1:batches-1;
indx = nb.*f;
c=1;
d=1;
lpBar = zeros(batches-1,1);
for i = 1:batches-1
    s = sample(d:indx(c),:);
    [row,~] = size(s);
    d = indx(c)+1;
    if sum(s(:,:)) < 1e-18
        lpBar(c) = 1;
    else
        lpBar(c) = logProbability(row, s);
    end
    c = c + 1;
end
lastBatchLen = length(d:N);
lpBar(batches) = logProbability(lastBatchLen, sample(d:N,:));
lpBarBar = mean(lpBar);
weight1 = lastBatchLen/(batches-1);
ssr = sum((lpBar - lpBarBar).^2, 'omitnan');
sHatSqd = sqrt((1/N)*weight1*ssr);
end

