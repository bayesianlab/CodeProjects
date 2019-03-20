function [avgBeta, avgs] = mvProbit(y,X, beta, R, ystar, Sims)

[K, T] = size(y);
dimX = size(X,2);

sumBeta = zeros(dimX,1);
betaDraw = beta;
ys = y;
mustar = reshape(X*beta, K,T);
s = zeros(K,K);
for k = 1:Sims
    
    mu = reshape(X*betaDraw, K,T);
    
    ys = updateYstar(y, mu, R, mustar);
%     ys = mvnrnd(mu', R)';
    
    z = (ys - mu);
    zzp = z*z';
    zzp12 = diag(zzp).^(-.5);
    s = s + diag(zzp12)*zzp*diag(zzp12);

    betaDraw = mvprobitDrawBeta(ys,X,R)
    sumBeta = sumBeta + betaDraw;
        
    
end
avgs = s./Sims;
avgBeta = sumBeta/Sims;
end

