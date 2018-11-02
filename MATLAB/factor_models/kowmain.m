clear;clc;
importkow
y = table2array(kow1(:,2:end))';
[T, kowc] = size(y);

[yt,Xt] = lagYt(y',3);
yt = yt';
[K,T]= size(yt);



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

ys = kd(:,1:5:end);
ys = ys';


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
rng(1)
kowdynfactorgibbs(ys, kd,restrictedvar, b0, inv(B0),1 );

% X = full(X);
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

% a = zeros(5,1);
% rng(1.5)
% a = ones(5,1).*-Inf;
% b = ones(5,1).*Inf;
% mu = normrnd(3,1, 5,1)
% Sigma = wishrnd(eye(5), 10);
% mean(geweke91T(a,b,mu,Sigma, 10, 100000),2)
% p = [5,3;3,15]
% pin = p\eye(2)
% pind = diag(pin);
% cm=  1- (1/pin(2,2))*pin(2,1)
% cv = pin(2,2)^(-1);
% x=[2;2]
% m = [1;1]
% normpdf(2,1,sqrt(5))*normpdf(2,cm,sqrt(cv))
% mvnpdf(x, m, p)
% cv = ((10 + pin(1,1))/11)*(1/pin(2,2))
% mvstudenttpdf(2,1,5,10)
% mvstudenttpdf([2;2],[1;1],p,10)
% 
% mvstudenttpdf(2,1,5, 10) + mvstudenttpdf( 2,cm,cv,11)
% 
% log(tpdf(1/sqrt(5),  10)*1/sqrt(5))
% mvstudenttpdf(2,1,5,10)
