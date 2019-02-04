function [ retval ] = unrestricteDraw( x0, yt, obsPrecision, Ft, FtPrecision,...
    nEqns, lastMean, lastHessian, options  )

ObsPriorMean = ones(1, nEqns);
ObsPriorPrecision = eye(nEqns).*1e-5;
LogLikePositive = @(v) AproptoLL (v, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
LL = @(guess) -AproptoLL(guess, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
[themean, ~,exitflag,~,~, Hessian] = fminunc(LL, nx, options);
[~, p] = chol(Hessian);
[themean, Hessian, lastMean, lastHessian] = ...
    optimCheck(p, themean,Hessian, lastMean, lastHessian);
V = Hessian \ eye(length(themean));

proposal  = themean + chol(V,'lower')*normrnd(0,1,length(themean),1)./w1;
proposalDist = @(q) mvstudenttpdf(q, themean', V, df);

Num = LogLikePositive(proposal) + proposalDist(x0);
Den = LogLikePositive(x0) + proposalDist(proposal');
alpha = Num - Den;
if log(unifrnd(0,1,1)) <= alpha 
    retval = [ 1;proposal ];
else
   retval = x0; 
end
end

