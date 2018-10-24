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


kd = prepKow(y',3);
lags = 3;
b0 = zeros(lags+1,1); 
B0 = 100.* eye(length(b0));
restrictedvar = 1;



% gamma = [-1,-2,-.4]
% onevec = ones(T, 3);
% onevec(1,2) = 0 ;
% onevec(1,3) = 0;
% onevec(2,3) = 0;
% diagvec = [onevec.*gamma, ones(T,1)]
% 
% H = full(spdiags(diagvec, [-3:0], T,T))
% H*kron(eye(T), 2)*H'
% full(spdiags([ones(T,1).*gamma, ones(T,1)], [-3:-1, 0], T,T))

kowdynfactorgibbs(kd,restrictedvar, b0, inv(B0),1 )
% rng(1)
% Sigma = normrnd(0,1,5,5)
% 
% A = normrnd(0,1, 5,1) 
% S1= 4
% B = normrnd(0,1,5,1)
% S2 = 3
% C = normrnd(0,1,5,1)
% S3 = 5;
% inv(Sigma + A*S1*A' + B*S2*B' + C*S3*C')
% recursiveWoodbury(Sigma, A, S1, B,S2, C,S3)