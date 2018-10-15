% re learn factor models
clear;clc;
rng(14)
K = 4;
T = 100;
nu = 10;
lag = 1;
om = 1;
sii2 = ones(K,1);
mu = ones(K,1);
G = ones(K,K).*[.75,.5,-.6,-.9];
a = ones(K-1,1).*.75;
ap = [1;a ];
g = .5;
epst = mvnrnd(zeros(K,1), diag(sii2), T+1)';
vut = normrnd(0,om, T+1,1);
yt = zeros(K,T+1);
ft = zeros(1,T+1);
state0 = 0;
initialStateVar = om/(1-g^2);
ft(1) = normrnd(0,initialStateVar);
yt(:,1) = epst(:,1);

for i = 2:(T+1)
    yt(:,i) = mu + G*yt(:,i-1) + ap*ft(i-1) + epst(:,i);
    ft(i) = g*ft(i-1) + vut(i);
end
ytorig = yt;
beta= [mu,G];
ytlag = yt(:,1:T);
Xtest = [ones(1,T);ytlag];
ytlag =[ones(1,T);ytlag]'; 
yt = yt(:,2:T+1);
yt*Xtest' *inv(Xtest*Xtest');
Xt = repmat(kron(eye(K), ones(1,K+1)),T,1)...
    .*repmat(kron(ytlag, ones(K,1)),1,K);
[rowX, colX] = size(Xt);

e = epst(:,2:T+1);
S = ones(T,1).*om;
% S(1) = initialVar;
S = diag(S);
h = [ones(T,1).*(-g), ones(T,1), ones(T,1).*(-g)];
p = full(spdiags(h,[-1,0],T,T));
F0 = p*S*p';
Sdiag = diag(F0);
F0i = F0\eye(size(F0,1));
apriormean = zeros(length(a),1);
apriorcov = eye(length(a)).*100;
b0 = zeros(colX,1); 
B0 = 100.* eye(colX);
b = beta';
yh = yt(:);
mu = Xt*b(:);
statepriormean = 0;
statepriorcov = 1;
sigmaPriorParamA = 5;
sigmaPriorParamB = 10;
stateVariancePriorParamA = 5;
stateVariancePriorParamB = 10;
% index =1:K;
% xpxsum = zeros(colX,colX);
% xpysum = zeros(colX,1);

% for t = 1:T
%     select = index + (t-1)*K;
%     xpysum = xpysum + Xt(select,:)'*yh(select);
%     xpxsum = xpxsum + Xt(select,:)'*Xt(select,:);
% end
% bols = inv(xpxsum)*xpysum;
% dll = @(guess) DmarginalLogLikelihood(yh,mu,sii2,guess,diag(F0i));
% [ag,bt] = bhhh([0;0;0], dll, 100, 1e-3, .5)
% mhStepForA(yh, mu, sii2, diag(F0i), dll, [0;0;0],...
%     apriormean, apriorcov, nu)


% forwardBackwardSmoother(yh,mu, diag(sii2), g, ap, 0, initialVar, nu)
dynfacgibbs(yt(:),Xt,a, g, sii2, om, b0, B0, apriormean,...
    apriorcov, state0, initialStateVar, statepriormean,...
    statepriorcov, sigmaPriorParamA, sigmaPriorParamB,...
    stateVariancePriorParamA, stateVariancePriorParamB, 100) 