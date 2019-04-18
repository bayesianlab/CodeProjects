function [neighbors] = nearest_neighbor(Nsquares)
NsquaresSquared = Nsquares^2;
neighbors = zeros(NsquaresSquared, NsquaresSquared);
points = 1:Nsquares;
colCount = 1;
rowCount = 0;
for q = 1:Nsquares
    for p = 1:Nsquares
        rowCount = rowCount + 1;
        BasePoint = [q,p];
        startColLoop = p+1;
        for j = q:Nsquares
            for k = startColLoop:Nsquares
                colCount = colCount + 1;
                D = [points(j), points(k)];
                if sum((BasePoint - D).^2) <= 2
                    neighbors(rowCount, colCount) = 1;
                end
            end
            startColLoop = 1;
        end
        colCount = rowCount+1;
    end
end
neighbors = neighbors + neighbors';
end

