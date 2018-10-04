function [betabar, stoB, R0bar, acceptrate, r0Elems, stoR0 ] = liu2006(y,X, b0, B0,...
    wishartDf, D0, R0, Sims, r0indxs, tz)
% y is expected as [y11,..., y1T; 
%                   y21,...,y2T]
% Dimension sizes needed
% X is longitudnal data
% subject Xij = [1, x(i,1,...J)]
if floor(.1*Sims) > 1
    burnin = floor(.1*Sims);
else
    burnin = 1;
end
[r,c] = size(X);
[K,~]= size(R0);
SampleSize = r/K;
% Prior initialization
B=b0;
B0inv = inv(B0);
BpriorsPre = B0inv*b0;
z = y;
R0avg = R0;

% Storage containers and intialize local vars. 
lu = log(unifrnd(0,1,Sims,1));
s1 = zeros(c,c);
s1eye = eye(c,c);
r0i = eye(K);
s2= zeros(c,1);
tempSum1 = s1;
tempSum2=s2;
accept = 0;
stoB = zeros(Sims, c);
trackingNum = size(r0indxs,1);
r0Elems = zeros(Sims-burnin, trackingNum);
postDraws = 0;
accept = 0;
stoR0 = zeros(K, K, Sims-burnin);

for i = 1 : Sims
    mu = X*B;
    reshapedmu = reshape(mu, K, SampleSize);
    z = updateLatentZ(y,reshapedmu, R0);
    % Correlation Matrix Part
    % Correlation Matrix Part
    ystar = D0*(z - reshapedmu);
    WishartParameter = ystar*ystar';
    dw = diag(WishartParameter);
    idwhalf = dw.^(-.5);
    Sstar = diag(idwhalf) * WishartParameter * diag(idwhalf)
    canW = iwishrnd(Sstar, wishartDf);
    d0 = diag(canW).^(.5);
    canD = diag(d0);
    canD0i = diag(d0.^(-1));
    canR = canD0i * canW * canD0i;
    mhprob = min(0,logdet(canR) - logdet(R0))
    if lu(i) < mhprob
        accept = accept + 1;
        R0 = canR;
        D0 = canD;
        W0 = canW;
    end
    if i > burnin
        postDraws = postDraws + 1;
        for k = 1:trackingNum
            r0Elems(postDraws,k) = R0(r0indxs(k,1), r0indxs(k,2));
        end
       R0avg = R0avg + R0;
       stoR0(:,:,postDraws) = R0;
    end
    R0i = R0\r0i;
    index =1:K;
    for k = 1:SampleSize
        select = index + (k-1)*K;
        tempSum1 = tempSum1 + X(select, :)'*R0i*X(select,:);
        tempSum2 = tempSum2 + X(select, :)'*R0i*z(:,k);
    end
    B0 = (tempSum1)\s1eye;
    L= chol(B0,'lower');
    b0 = B0*(tempSum2);
    B = b0 + L*normrnd(0,1,c,1);
    stoB(i,:) = B';
    tempSum1=s1;
    tempSum2=s2;
    fprintf('%i\n', i)
end
R0bar= R0avg/(Sims-burnin + 1);
acceptrate = accept/Sims;
betabar = mean(stoB(burnin:end,:),1);

end

