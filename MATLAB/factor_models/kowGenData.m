function [y, SurX] = kowGenData()

kowImport
alldata = table2array(kowdata(:,2:end))';

lags = 3;
kd = kowPrepKowData(alldata',lags);
b0 = zeros(lags+1,1); 
B0 = 100.* eye(length(b0));
restrictedvar = 1;

dexsy = 1:5:size(kd,2);
dexsx = setdiff(1:size(kd,2), dexsy);
y = kd(:,dexsy)';

[K, T] = size(y);
Xs = kd(:, dexsx);
spcolX = speye(K);
formsurI = kron(spcolX, ones(1,4));

SurX = zeros(K*T, size(Xs,2));
t = 1:K;

for r = 1:size(Xs,1)
    select = t + (r-1)*K;
    SurX(select, :) = formsurI.*Xs(r,:);
end

end

