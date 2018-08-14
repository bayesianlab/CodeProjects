function [betabar, R0bar, acceptrate] = mv_probit(y,surX, b0, B0, Sigma0,Sims)
% y is expected as [y11,..., y1T; 
%                   y21,...,y2T]

[r,c] = size(surX);
[neqns,~]= size(Sigma0);
N = r/neqns;

B=b0;
B0inv = inv(B0);
BpriorsPre = B0inv*b0;
Sinv = inv(Sigma0);

WishartPrior = createSigma(.5, neqns);
D0 = eye(neqns)*.5;
R0 = WishartPrior;
W0 = D0*R0*D0;
w0 = 2;
lu = log(unifrnd(0,1,Sims,1));
s1 = zeros(c,c);
s2= zeros(c,1);
s1a = s1;
s2a=s2;
z = double(y);
accept = 0;
R0avg = R0;

stoB = zeros(Sims, c);
burnin = floor(.1*Sims);
for i = 1 : Sims
    mu = surX*B;
    reshapedmu = reshape(mu, neqns,N);
    z = updateLatentZ(y',reshapedmu', R0, z)';
    R0i = inv(R0);
    t=1;
    for k = 1:N
        tend = t + neqns - 1;
        s1a = s1a + surX(t:tend, :)'*R0i*surX(t:tend,:);
        s2a = s2a + surX(t:tend, :)'*R0i*z(:,k);
        t = tend + 1;
    end
    B0 = inv(B0inv + s1a);
    b0 = B0*BpriorsPre +  (B0 * s2a);
    s1a=s1;
    s2a=s2;
    B = b0 + chol(B0,'lower')*normrnd(0,1,c,1);
    stoB(i,:) = B';
    [W, D, R] = mhstep_mvprobit(w0, W0);
    Num = logpxWishart(D,R,w0,WishartPrior) + ...
         surLL(z,reshapedmu,R) + ...
        logWishart(W0, W, w0);
    Den = logpxWishart(D0,R0,w0,WishartPrior) + ...
        surLL(z,reshapedmu,R0) + ...
        logWishart(W, W0, w0);
    alpha = min(0, Num - Den);
    if lu(i) < alpha
        accept = accept + 1;
        D0 = D;
        R0 = R;
        W0 = W;
    end
    if i > burnin
       R0avg = R0avg + R0;
    end
    
end
R0bar= R0avg/(Sims-burnin + 1);
acceptrate = accept/Sims;
betabar = mean(stoB(burnin:end,:));
end