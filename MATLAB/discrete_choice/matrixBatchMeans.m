function [s] = matrixBatchMeans(batches, Matrix)
[r,~,N] = size(Matrix);
batchSize =  floor(N / batches);
intervals = 1:batches;
intervals(2:batches) = (1:batches-1).*batchSize;
yBar = zeros(r,r,batches);
for i = 1:length(intervals)-1
    yBar(:,:,i) = mean(Matrix(:,:, intervals(i):intervals(i+1)),3);
end
yBar(:,:,batches) = mean(Matrix(:,:,intervals(batches):N),3);
s= std(yBar,[], 3);
end

