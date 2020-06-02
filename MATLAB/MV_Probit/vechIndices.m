function [s] = vechIndices(K)
I = 2:K;
s = zeros(K-1,2);
s(1,1) = 1;
for i = 1:K-2
    s(i+1,1) = s(i,1) + K - i;
    s(i,2) = s(i+1,1) -1;
end
s(K-1,2) = s(K-1,1);
end

