function [avgBeta, avgs] = mvProbit(y,X, beta, Rk, ystar, Sims, burnin)

[K, T] = size(y);
dimX = size(X,2);

sumBeta = zeros(dimX,1);
betaDraw = beta;
s = zeros(K,K);
mhparam = .5*(K+1);
lu = log(unifrnd(0,1, Sims,1));

vechRk = vech(Rk);
sigma0 = .1.*eye(length(vechRk));
Q = ystar(:)-X*beta;
iCommuteMat = InverseCommute(vechRk, K);
loglike = @(g)-SigmaMaximize(g,sigma0,iCommuteMat, Q, K, T)
options = optimoptions(@fminunc, 'Display', 'iter', 'MaxFunctionEvaluations', 10000)
fminunc(loglike, vechRk, options)
for k = 1:Sims
%     fprintf('Simulation %i\n', k)
%     logdetRk = 2*sum(log(diag(chol(Rk))));
%     
%     mu = reshape(X*betaDraw, K,T);
%     
%     ys = updateYstar(y, mu, Rk);
%     
%     z = (ys - mu);
%     zzp = z*z';
%     zzp12 = diag(zzp).^(-.5);
%     Rkp1 = diag(zzp12)*zzp*diag(zzp12);
%     [LR, p]  = chol(Rkp1);
%     logdetRkp1 = 2*sum(log(diag(LR)));
%     alpha = min(0, mhparam*(logdetRkp1 - logdetRk));
%     if p == 0
%         if lu(k) < alpha
%             Rk = Rkp1;
%         end
%         
%     end
%     
%     
%     betaDraw = mvprobitDrawBeta(ys,X,Rk);
%     
%     if k > burnin
%         s = s + Rk;
%         sumBeta = sumBeta + betaDraw;
%     end
%     
end
% Runs = Sims-burnin;
% avgs = s./Runs;
% avgBeta = sumBeta/Runs;
end

