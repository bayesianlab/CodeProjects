clear;clc;
importkow
y = table2array(kow1(:,2:end))';
[T, kowc] = size(y);

[yt,Xt] = lagYt(y',3);
yt = yt';
[K,T]= size(yt);



kd = prepKow(y',3);
lags = 3;
b0 = zeros(lags+1,1); 
B0 = 100.* eye(length(b0));
restrictedvar = 1;

dexsy = 1:5:size(kd,2);
dexsx = setdiff(1:size(kd,2), dexsy);
ys = kd(:,dexsy);
ys = ys';
Xs = kd(:, dexsx);
spK = speye(K);
formsurI = kron(spK, ones(1,4));

surx = zeros(K*T, size(Xs,2));
t = 1:K;

for r = 1:size(Xs,1)
    select = t + (r-1)*K;

    surx(select, :) = formsurI.*Xs(r,:);
end



rng(1)
kowdynfactorgibbs(ys, surx, kd,restrictedvar, b0, inv(B0),1 );


