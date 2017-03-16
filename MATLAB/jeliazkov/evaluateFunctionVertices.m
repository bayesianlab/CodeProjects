function [ vals ] = evaluateFunctionVertices( points, fun)
[~,nPoints] = size(points);
vals = zeros(nPoints, 2);
for i = 1:nPoints
    vals(i,1) = i;
    vals(i,2) = fun(points(:, i));
end
end

