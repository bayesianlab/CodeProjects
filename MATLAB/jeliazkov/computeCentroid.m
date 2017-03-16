function [ center] = computeCentroid(initialSimplex, indices)
[r,~] = size(initialSimplex);
sum = 0;
for i = 1:r
    sum = sum + initialSimplex(:, indices(i));
end
center = sum./r;
end

