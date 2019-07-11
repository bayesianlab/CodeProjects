function [Q] = reshuffle(yt, nSeriesY, nGroupsY)
[K,T] = size(yt);
B = zeros(nGroupsY, K);
cols = [1, (1:nSeriesY)*nSeriesY + 1];
rows= 1:nGroupsY;
for i = 1:nGroupsY
    B(rows(i), cols(i)) = 1;
end
Q = zeros(K, K);
t = 1:nGroupsY;
Q(t, :) = B;
for p = 1:nSeriesY-1
    s = t + p*nGroupsY;
    Q(s,:) = circshift(B,p,2);
end
end

