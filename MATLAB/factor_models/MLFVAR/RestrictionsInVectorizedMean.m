function [RestrictedIndices] = RestrictionsInVectorizedMean(InfoCell, FactorIndices)
y = cellfun(@(x)size(x,1), InfoCell);
cols = length(y);
nFactors = sum(y);
RestrictedIndices = zeros(nFactors,1);
for c = 1:cols
    Restrictions = InfoCell{1,c};
    Ind = (Restrictions(:,1) - 1).*cols + c;
    RestrictedIndices(FactorIndices(c,1):FactorIndices(c,2),1) = Ind;
end
RestrictedIndices =  sort(RestrictedIndices);
end

