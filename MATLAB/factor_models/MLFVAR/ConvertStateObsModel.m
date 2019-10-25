function [Store] = ConvertStateObsModel(Gt, FactorIndices)
Store = zeros(size(Gt(:,1), 1),size(FactorIndices,1));
for n = 1:size(FactorIndices,1)
    Store(:,n) = sum(Gt(:,FactorIndices(n,1):FactorIndices(n,2)),2);
end
end

