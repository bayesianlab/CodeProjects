function [SectorIndices] = SetIndicesInFactor(InfoCell)
levels = size(InfoCell,2);
Factors = cellfun(@(x)size(x, 1), InfoCell);
start = 1;
SectorIndices =zeros(levels, 2);
nf = 0;
for q = 1:levels
    nf = nf + Factors(q);
    SectorIndices(q,:) = [start,   nf];
    start = nf+1;
end

end

