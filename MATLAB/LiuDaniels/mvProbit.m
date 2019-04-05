function [avgBeta, avgs] = mvProbit(y,X, beta, Rk, ystar, Sims, burnin)

[K, T] = size(y);
dimX = size(X,2);

sumBeta = zeros(dimX,1);
betaDraw = beta;
s = zeros(K,K);
mhparam = .5*(K+1);
lu = log(unifrnd(0,1, Sims,1));

vechRk = vech(Rk,-1);

sigma0 = .1.*eye(length(vechRk));
iCommuteMat = TransformMatrix(vechRk, K);
loglike = @(g)-SigmaMaximize(g,sigma0,iCommuteMat, Q, K, T);
options = optimoptions(@fminunc, 'Display', 'off', 'MaxFunctionEvaluations', 5000);



for k = 1:Sims
    fprintf('Simulation %i\n', k)
    
    
    mu = reshape(X*betaDraw, K,T);
    
    ys = updateYstar(y, mu, Rk);
    betaDraw = mvprobitDrawBeta(ys,X,Rk);
     
    Q = ys(:)-X*betaDraw;
    loglike = @(g)-SigmaMaximize(g,sigma0,iCommuteMat, Q, K, T);
    p  = fminunc(loglike,vechRk, options);
    p = reshape(iCommuteMat*p, K,K);
    p =  p + p' + eye(K);
    p = iwishrnd(p,T);
    phalf = diag(p).^(-.5);
    pdraw = diag(phalf)*p*diag(phalf)
    logdetRkp1 = 2.*sum(log(diag(chol(pdraw))));
    logdetRk = 2*sum(log(diag(chol(Rk))));
    
    alpha = min(0, mhparam*(logdetRkp1 - logdetRk));
    if lu(k) < alpha
        Rk = pdraw;
    end

   
    
    if k > burnin
        s = s + Rk;
        sumBeta = sumBeta + betaDraw;
    end
    
end
Runs = Sims-burnin;
avgs = s./Runs;
avgBeta = sumBeta/Runs;
end

