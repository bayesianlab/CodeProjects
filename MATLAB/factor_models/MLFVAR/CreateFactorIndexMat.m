function [FMat] = CreateFactorIndexMat(InfoCell)
J = InfoCell{1};
levels = length(InfoCell);
FMat = zeros(length(J(1):J(2)), levels);
c=0;
for u = 1:levels
    RowInds = InfoCell{u};
    rows = size(RowInds,1);
    for q = 1:rows
        c = c + 1;
        for w = RowInds(q,1):RowInds(q,2)
            FMat(w,u) = c;
        end
    end
end
end

