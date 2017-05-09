function [ notJIndices ] = notJindxs(J)
yDim = 1:J;
notJIndices = zeros(J, J-1);
for j = 1:J
    notJIndices(j,:) = yDim(j ~= yDim);
end
end

