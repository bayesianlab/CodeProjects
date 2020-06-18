function [factorInfo] = factorIndices(sectorInfo)
lsi = length(sectorInfo);
factorInfo = zeros(lsi,2);
count = 0;
for w = 1:length(sectorInfo)
    count = count + sectorInfo(w);
    factorInfo(w,:) = [count - sectorInfo(w) + 1,count];
end
end

