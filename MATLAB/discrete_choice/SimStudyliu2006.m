function [  ] = SimStudyliu2006( Sims)
if ischar(Sims)
    Sims = str2num(Sims);
end
N = 200;
K = 7;
R = [1, .8, .6, .4, .2, 0, 0;
    .8, 1, .8, .6, .4, .2, 0;
    .6, .8, 1, .8, .6, .4, .2;
    .4, .6, .8, 1, .8, .6, .4;
    .2, .4, .6, .8, 1, .8, .6;
    0, .2, .4, .6, .8, 1, .8;
    0, 0, .2, .4, .6, .8, 1];
iR = inv(R);
beta = [.5, .8,.3]';
Covariates = length(beta);
b0 = zeros(length(beta),1);
B0 = eye(length(b0))*10;
wishartDf = N;
W0 = wishrnd(eye(K), wishartDf)./wishartDf;
D0 = diag(W0).^(.5);
R0 = diag(D0.^(-1))*W0*diag(D0.^(-1));
timetrend =(1:K)'-4;
t = 1:K;
for i = 1:N
    select = t + (i-1)*K;
    X(select, :) = [ones(K,1), timetrend, normrnd(0,3,K,1)];
end
E=mvnrnd(zeros(K,1),R, N)';
vecz = X*beta + E(:);
vecy = double(vecz>0);
y = reshape(vecy, K,N);
z = reshape(vecz, K,N);

[bbar, r0,ar, postr0,~] = liu2006(y, X, b0, B0, wishartDf, diag(D0), R0,...
    Sims, [2,1]);
r0ir = r0*iR;
steinloss = trace(r0ir) - logdet(r0ir) - size(r0,1);
save('simres.mat')

end

