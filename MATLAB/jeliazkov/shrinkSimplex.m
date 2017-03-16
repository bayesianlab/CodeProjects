function [ simplex ] = shrinkSimplex( simplex, indices, delta )
lIndices = length(indices(:,1));
for k = 2:lIndices
    simplex(:,k) = simplex(:,indices(1)) + delta.*(simplex(:,k) -...
        simplex(:,indices(1)) );
end

end

