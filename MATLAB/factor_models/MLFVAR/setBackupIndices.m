function [backupIndices] = setBackupIndices(BlockingInfo)
levels = length(BlockingInfo);
backupIndices = zeros(2, levels);
h = 1;
e=0;
for g = 1:levels
    e = e + size(BlockingInfo{g},1);
    backupIndices(1,g) = h;
    backupIndices(2,g) = e;
	h = h+size(BlockingInfo{g},1);
end
end

