function [ retval, lastMean, lastHessian] = unrestrictedDraw( x0, yt, obsPrecision, Ft, FtPrecision,...
    nEqns, lastMean, lastHessian, options  )
df = 20;
w1 = sqrt(chi2rnd(df,1)/df);
ObsPriorMean = .5.*ones(1, nEqns);
ObsPriorPrecision = eye(nEqns).*1e-3;

LogLikePositive = @(v) AproptoLL (v, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
LL = @(guess) -AproptoLL(guess, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
[themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);

% check = kowMHR(x0,themean,Hessian, yt,obsPrecision,ObsPriorMean, ObsPriorPrecision\eye(length(themean)), Ft, FtPrecision)
[~, p] = chol(Hessian);
[themean, Hessian, lastMean, lastHessian] = ...
    optimCheck(p, themean,Hessian, lastMean, lastHessian);
V = Hessian \ eye(length(themean));
n = length(themean);
proposal = themean + chol(V, 'lower')*normrnd(0,1, n,1)./w1;
% if proposal(1) < 0    
%     sigma = sqrt(V(1,1));
%     alpha = -(themean(1)*w1)/sigma;
%     z = truncNormalRand(alpha, Inf,0, 1);
%     restricteddraw = themean(1) + (sigma*z)/w1;
%     lower = themean(2:n) + chol(V(2:n,2:n), 'lower')*normrnd(0,1, n-1,1)./w1;
%     proposal = [restricteddraw;lower];
% end
proposalDist = @(q) mvstudenttpdf(q, themean', V, df);

Num = LogLikePositive(proposal) + proposalDist(x0');
Den = LogLikePositive(x0) + proposalDist(proposal');
alpha = Num - Den;
u = log(unifrnd(0,1,1));
if u <= alpha 
    retval = proposal;
else
   retval = x0; 
end
end

