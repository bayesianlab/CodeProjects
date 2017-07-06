function [ s ] = batchMeans(batches, mcmcSample)
[N,~] = size(mcmcSample);
batchSize =  floor(N / batches);
intervals = ones(batches+1,1);
intervals(2:batches+1) = ((1:batches).*batchSize) + 1;
yBar = zeros(batches+1, 1);
for i = 2:batches+1
    yBar(i-1) = mean(mcmcSample(intervals(i-1):intervals(i)-1));
end
yBar(batches+1, 1) = mean(mcmcSample(intervals(batches+1):N) );
s = std(yBar);
end

