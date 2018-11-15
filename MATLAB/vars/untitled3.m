clear;clc;
importkow
y = table2array(kow1(:,2:end))';
[T, kowc] = size(y);

[yt,Xt] = lagYt(y',3);
yt = yt';
[K,T]= size(yt);

size(yt(:))

% testx=repmat(kron(eye(kt), ones(1,3*kt+1)),tt,1)...
%     .*repmat(kron(Xt, ones(K,1)), 1,K)

% ylag = y(1:end-3, :);
% yt = y(4:end, :);
% 
% 
% Xt = [ones(kowc,1)';ylag]'
% kron(Xt, ones(kowc,1))

keySet = kow1.Properties.VariableNames(2)
valueSet = kow1.rgdpnaUSA
containers.Map(keySet, valueSet)