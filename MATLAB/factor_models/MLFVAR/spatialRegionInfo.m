function [ regionInfo, regionFactors] = spatialRegionInfo(yassignment)
uni = unique(yassignment);
Nuni = length(uni);
b=1;
regionFactors = Nuni;
regionInfo = zeros(Nuni,2);
for q = 1:Nuni
    n = sum(yassignment==uni(q));
    e = b+n-1;
    regionInfo(q,:) = [b,e];
    b= e+1;
end
end

