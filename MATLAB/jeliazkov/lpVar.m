function [ vbatch ] = lpVar(sample, batches)
[tr,c] = size(sample);
if tr<c
    sample = sample';
    [tr,~] = size(sample);
end
f = floor(tr/batches);
nb = 1:batches-1;
indx = nb.*f;
c=1;
d=1;
lpBar = zeros(batches-1,1);
for i = 1:batches-1
    s = sample(d:indx(c),:);
    [row,~] = size(s);
    d = indx(c)+1;
    lpBar(c) = logProbability(row, s);
    c = c + 1;
end
lastBatchLen = length(d:tr);
lpBar(batches) = logProbability(lastBatchLen, sample(d:tr,:));
lpBarBar = mean(lpBar);
weight1 = 1/(batches*(batches-1));
weight2 = sqrt((batches*lastBatchLen)/tr);
ssr = sum((lpBar - lpBarBar).^2);
vbatch = 100*weight2*sqrt(weight1*ssr);
end

