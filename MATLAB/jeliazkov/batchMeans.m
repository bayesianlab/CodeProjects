function [ s ] = batchMeans(batches, mcmcSample)
[N,~] = size(mcmcSample);
batchSize =  floor(N / batches);
intervals = 1:batches;
intervals(2:batches) = (1:batches-1).*batchSize;
yBar = zeros(batches,1);
for i = 1:length(intervals)-1
    yBar(i) = mean(mcmcSample(intervals(i):intervals(i+1), :));
end

yBar(batches) = mean(mcmcSample(intervals(batches):N, :));
s = std(yBar);
end

