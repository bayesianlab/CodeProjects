function [ retval ] = restrictedDraw(x0, yt, obsPrecision, Ft, FtPrecision,...
    nEqns, lastMean, lastHessian, options )
df = 20;
ObsPriorMean = ones(1, nEqns-1);
ObsPriorPrecision = eye(nEqns-1).*1e-5;
w1 = sqrt(chi2rnd(df,1)/df);
LogLikePositive = @(v) AproptoLLLevel3 (v, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);

LL = @(guess) -AproptoLLLevel3(guess, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);


[themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
themean = themean(2:end);
Hessian = Hessian(2:end,2:end);
[~, p] = chol(Hessian);
[themean, Hessian, lastMean, lastHessian] = ...
    optimCheck(p, themean,Hessian, lastMean, lastHessian);

V = Hessian \ eye(length(themean));

proposal  = themean + chol(V,'lower')*normrnd(0,1,length(themean),1)./w1;
proposalDist = @(q) mvstudenttpdf(q, themean', V, df);

Num = LogLikePositive([1;proposal]) + proposalDist(x0(2:end)');
Den = LogLikePositive(x0) + proposalDist(proposal');
alpha = Num - Den;
if log(unifrnd(0,1,1)) <= alpha 
    retval = [ 1;proposal ];
else
   retval = x0; 
end

end

