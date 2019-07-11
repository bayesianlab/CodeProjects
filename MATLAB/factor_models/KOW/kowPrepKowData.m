function [ X ] = kowPrepKowData( kowdata, lag)
% lags kowdata one column at a time
[r,c] = size(kowdata);
X = zeros(r-lag, c*(lag+1));
size(X)
t = 1:;
for i = 1:c
    select = (i-1)*(lag+2) + t;
    [y,x] = lagYt(kowdata(:,i),lag);
    X(:, select) = [y,x];
end

end

