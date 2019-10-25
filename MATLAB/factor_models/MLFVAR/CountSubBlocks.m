function [sto] = CountSubBlocks(RegionBlock, subGroup)
sto = zeros(1, size(RegionBlock,1));
for n = 1:size(RegionBlock,1)
    sto(n) = find(RegionBlock(n,2) == subGroup(:,2));
end
sto =[sto(1), diff(sto)];
end

